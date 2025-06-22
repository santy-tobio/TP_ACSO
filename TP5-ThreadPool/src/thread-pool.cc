/**
 * File: thread-pool.cc
 * --------------------
 * Presents the implementation of the ThreadPool class.
 */

#include "thread-pool.h"
#include <stdexcept>
using namespace std;

ThreadPool::ThreadPool(size_t numThreads) : wts(numThreads), done(false) {

    for (size_t i = 0; i < numThreads; i++) {
        wts[i].ts = thread(&ThreadPool::worker, this, i);
        availableWorkers.push(i);  
    }

    dt = thread(&ThreadPool::dispatcher, this);
}

void ThreadPool::worker(int id) {

    while (!done) {
        wts[id].workReady.wait();
        if (!done && wts[id].thunk) {
            wts[id].thunk();
            
            {
                lock_guard<mutex> lock(queueLock);
                availableWorkers.push(id);
                allTasksDone.notify_all(); 
                anyWorkerAvailable.notify_all();
            }
        }
    }
}

void ThreadPool::dispatcher() {
    while (!done) {
        
        dispatcherSemaphore.wait(); // esperamos la señal del schedule() , nos garantiza que haya tareas
        if (done && taskQueue.empty()) break; 
        
        function<void(void)> task;
        int workerId;
        
        {
            unique_lock<mutex> lock(queueLock);
            anyWorkerAvailable.wait(lock, [this]() {
                return !availableWorkers.empty();
            });
        }

        {
            lock_guard<mutex> lock(queueLock);
            task = taskQueue.front();
            taskQueue.pop();
            workerId = availableWorkers.front();
            availableWorkers.pop();
            wts[workerId].thunk = task; 
            wts[workerId].workReady.signal(); // es thread safe pero a helgrind no le gusta si la saco del mutex
        }
        
    }
}

void ThreadPool::schedule(const function<void(void)>& thunk) {
    
    if (!thunk) throw invalid_argument("Cannot schedule a null task");
    if (done) throw runtime_error("Cannot schedule tasks on a destroyed ThreadPool");

    {
        lock_guard<mutex> lock(queueLock);
        taskQueue.push(thunk);
    }
    
    dispatcherSemaphore.signal(); //thread safe
}
    
void ThreadPool::wait() {
    unique_lock<mutex> lock(queueLock);
    allTasksDone.wait(lock, [this]() {
        return taskQueue.empty() && availableWorkers.size() == wts.size();
    });
}

ThreadPool::~ThreadPool() {

    wait(); 
    done = true; // la convertí en atomica para no tener data races

    dispatcherSemaphore.signal();
    
    for (size_t i = 0; i < wts.size(); i++) {
        wts[i].workReady.signal(); 
    }

    dt.join(); // esperamos al dispatcher
    for (size_t i = 0; i < wts.size(); i++) {
        wts[i].ts.join(); // esperamos a los workers
    }
}
