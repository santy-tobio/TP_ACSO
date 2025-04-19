def binary_search_steps(arr, target):
    low = 0
    high = len(arr) - 1
    steps = 0
    
    while low <= high:
        steps += 1
        mid = (low + high) // 2
        mid_value = arr[mid]
        
        if mid_value == target:
            return steps
        elif mid_value < target:
            low = mid + 1
        else:
            high = mid - 1
    
    return -1  # Si la palabra no se encuentra

with open('palabras.txt', 'r', encoding='utf-8') as file:
    palabras = [line.strip() for line in file]

# solo palrabras que tienen entre 7 y 11 iteraciones del algoritmo
valid_inputs = []
for palabra in palabras:
    steps = binary_search_steps(palabras, palabra)
    if 7 <= steps <= 11:
        valid_inputs.append(f"{palabra} {steps}")

with open('inputs_validos_fase3.txt', 'w', encoding='utf-8') as file:
    for input_valido in valid_inputs:
        file.write(input_valido + '\n')
