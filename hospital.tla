(*

Sea la gestión de turnos de un hospital, donde:
    •   El hospital tiene una capacidad máxima de 10 personas.
    •   La atención de las personas se clasifica en 5 niveles de prioridad.
    •   Una persona puede acudir al hospital sin prioridad previa.
    •   En el caso de que una persona venga en ambulancia o a través de otro hospital, traerá un nivel de prioridad previa asignado.
    •   Si el hospital excede su capacidad, clasificará al paciente con una prioridad y será derivado a otro hospital.
El hospital dispone de 5 médicos que organizan su trabajo según la siguiente lista de prioridad:
    1.  Atender a los pacientes con prioridad 4 o 5.
    2.  Clasificar pacientes que no tengan un nivel de prioridad asignado.
    3.  Atender a los pacientes con nivel de prioridad 3 o inferior.
    4.  En caso de que el hospital se encuentre desbordado, se dará prioridad a la clasificación de pacientes y su derivación hasta volver a la capacidad máxima.

*)

------------------------------ MODULE hospital ------------------------------

EXTENDS TLC, Integers, Sequences, FiniteSets

Capacity == 10
Priority == 0..5

ExistsPriorityGreatherThan(pendingPatients, priority) ==
                \E x \in DOMAIN pendingPatients:
                    x > priority
                        
NoClasifiedPatients(pendingPatients) ==
                    \A x \in DOMAIN pendingPatients:
                        pendingPatients[x] = 0                      

(**--algorithm manageHospital

variables 
    patientsNumber \in 1..12,
    patients = [ x \in 1..patientsNumber |-> CHOOSE priority \in Priority: TRUE ] 
    
process Doctor \in 1..5
    variables
        currentPatient;
    
    begin
    AttendPatients:
        while patientsNumber > 0 do
            if patientsNumber > Capacity /\ NoClasifiedPatients(patients) then
               currentPatient := CHOOSE patient \in DOMAIN patients:
                                    patients[patient] = 0;
               patients := [x \in DOMAIN patients \ {currentPatient} |-> patients[x]];
               patientsNumber := patientsNumber - 1;
            elsif ExistsPriorityGreatherThan(patients, 3) \/ ~NoClasifiedPatients(patients) then
                currentPatient := CHOOSE patient \in DOMAIN patients:
                                    \A x \in DOMAIN patients:
                                        patients[patient] >= patients[x];
                patients := [x \in DOMAIN patients \ {currentPatient} |-> patients[x]];
                patientsNumber := patientsNumber - 1;
            elsif NoClasifiedPatients(patients) then
                currentPatient := CHOOSE patient \in DOMAIN patients:
                                    ~\E y \in DOMAIN patients:
                                        patients[patient] > patients[y];     
                patients[currentPatient] := CHOOSE x \in Priority: x /= 0;      
            end if;
         end while;
         
         assert Cardinality(DOMAIN patients) = patientsNumber;
    
end process;    

end algorithm; *)
\* BEGIN TRANSLATION
CONSTANT defaultInitValue
VARIABLES patientsNumber, patients, pc, currentPatient

vars == << patientsNumber, patients, pc, currentPatient >>

ProcSet == (1..5)

Init == (* Global variables *)
        /\ patientsNumber \in 1..12
        /\ patients = [ x \in 1..patientsNumber |-> CHOOSE priority \in Priority: TRUE ]
        (* Process Doctor *)
        /\ currentPatient = [self \in 1..5 |-> defaultInitValue]
        /\ pc = [self \in ProcSet |-> "AttendPatients"]

AttendPatients(self) == /\ pc[self] = "AttendPatients"
                        /\ IF patientsNumber > 0
                              THEN /\ IF patientsNumber > Capacity /\ NoClasifiedPatients(patients)
                                         THEN /\ currentPatient' = [currentPatient EXCEPT ![self] = CHOOSE patient \in DOMAIN patients:
                                                                                                       patients[patient] = 0]
                                              /\ patients' = [x \in DOMAIN patients \ {currentPatient'[self]} |-> patients[x]]
                                              /\ patientsNumber' = patientsNumber - 1
                                         ELSE /\ IF ExistsPriorityGreatherThan(patients, 3) \/ ~NoClasifiedPatients(patients)
                                                    THEN /\ currentPatient' = [currentPatient EXCEPT ![self] = CHOOSE patient \in DOMAIN patients:
                                                                                                                 \A x \in DOMAIN patients:
                                                                                                                     patients[patient] >= patients[x]]
                                                         /\ patients' = [x \in DOMAIN patients \ {currentPatient'[self]} |-> patients[x]]
                                                         /\ patientsNumber' = patientsNumber - 1
                                                    ELSE /\ IF NoClasifiedPatients(patients)
                                                               THEN /\ currentPatient' = [currentPatient EXCEPT ![self] = CHOOSE patient \in DOMAIN patients:
                                                                                                                            ~\E y \in DOMAIN patients:
                                                                                                                                patients[patient] > patients[y]]
                                                                    /\ patients' = [patients EXCEPT ![currentPatient'[self]] = CHOOSE x \in Priority: x /= 0]
                                                               ELSE /\ TRUE
                                                                    /\ UNCHANGED << patients, 
                                                                                    currentPatient >>
                                                         /\ UNCHANGED patientsNumber
                                   /\ pc' = [pc EXCEPT ![self] = "AttendPatients"]
                              ELSE /\ Assert(Cardinality(DOMAIN patients) = patientsNumber, 
                                             "Failure of assertion at line 64, column 10.")
                                   /\ pc' = [pc EXCEPT ![self] = "Done"]
                                   /\ UNCHANGED << patientsNumber, patients, 
                                                   currentPatient >>

Doctor(self) == AttendPatients(self)

Next == (\E self \in 1..5: Doctor(self))
           \/ (* Disjunct to prevent deadlock on termination *)
              ((\A self \in ProcSet: pc[self] = "Done") /\ UNCHANGED vars)

Spec == Init /\ [][Next]_vars

Termination == <>(\A self \in ProcSet: pc[self] = "Done")

\* END TRANSLATION

=============================================================================
\* Modification History
\* Last modified Mon Jul 08 20:23:13 CEST 2019 by jesus
\* Created Sun Jul 07 18:43:44 CEST 2019 by jesus