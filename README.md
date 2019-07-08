# Modelo de TLA+ de la gestión de turnos de un hospital

Mi primer modelo de TLA+, con fines de aprendizaje.

Sea la gestión de turnos de un hospital, donde:
- El hospital tiene una capacidad máxima de 10 personas.
- La atención de las personas se clasifica en 5 niveles de prioridad.
- Una persona puede acudir al hospital sin prioridad previa.
- En el caso de que una persona venga en ambulancia o a través de otro hospital, traerá un nivel de prioridad previa asignado.
- Si el hospital excede su capacidad, clasificará al paciente con una prioridad y será derivado a otro hospital.

El hospital dispone de 5 médicos que organizan su trabajo según la siguiente lista de prioridad:
1. Atender a los pacientes con prioridad 4 o 5.
2. Clasificar pacientes que no tengan un nivel de prioridad asignado.
3. Atender a los pacientes con nivel de prioridad 3 o inferior.
4. En caso de que el hospital se encuentre desbordado, se dará prioridad a la clasificación de pacientes y su derivación hasta volver a la capacidad máxima.
