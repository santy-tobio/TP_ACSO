### Antes correr:
```chmod +x 2hex.sh run_ref_sim.sh run_test_sim.sh```

Sino da error de permisos

### run_test_arm.sh
- Comando: `./run_test_arm.sh file.x`
- Hace: `make` en `src` y abre el simulador test con el archivo `file.x`

### run_ref_sim.sh
- Comando: `./run_ref_sim.sh file.x`
- Hace: Corre el simulador de referencia con el archivo `file.x`

### 2hex.sh
- Comando: `./2hex.sh file1.s file2.s ... fileN.s`
- Hace: Convierte los archivos `.s` a `.x`