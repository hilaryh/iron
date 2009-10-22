!> \file  
!> $Id: Navier_Stokes_equations_routines.f90 372 2009-04-20
!> \author Sebastian Krittian
!> \brief This module handles all Navier-Stokes fluid routines.
!>
!> \section LICENSE
!>
!> Version: MPL 1.1/GPL 2.0/LGPL 2.1
!>
!> The contents of this file are subject to the Mozilla Public License
!> Version 1.1 (the "License"); you may not use this file except in
!> compliance with the License. You may obtain a copy of the License at
!> http://www.mozilla.org/MPL/
!>
!> Software distributed under the License is distributed on an "AS IS"
!> basis, WITHOUT WARRANTY OF ANY KIND, either express or implied. See the
!> License for the specific language governing rights and limitations
!> under the License.
!>
!> The Original Code is OpenCMISS
!>
!> The Initial Developer of the Original Code is University of Auckland,
!> Auckland, New Zealand and University of Oxford, Oxford, United
!> Kingdom. Portions created by the University of Auckland and University
!> of Oxford are Copyright (C) 2007 by the University of Auckland and
!> the University of Oxford. All Rights Reserved.
!>
!> Contributor(s):
!>
!> Alternatively, the contents of this file may be used under the terms of
!> either the GNU General Public License Version 2 or later (the "GPL"), or
!> the GNU Lesser General Public License Version 2.1 or later (the "LGPL"),
!> in which case the provisions of the GPL or the LGPL are applicable instead
!> of those above. If you wish to allow use of your version of this file only
!> under the terms of either the GPL or the LGPL, and not to allow others to
!> use your version of this file under the terms of the MPL, indicate your
!> decision by deleting the provisions above and replace them with the notice
!> and other provisions required by the GPL or the LGPL. If you do not delete
!> the provisions above, a recipient may use your version of this file under
!> the terms of any one of the MPL, the GPL or the LGPL.
!>

!>This module handles all Navier-Stokes fluid routines.
MODULE NAVIER_STOKES_EQUATIONS_ROUTINES

  USE BASE_ROUTINES
  USE BASIS_ROUTINES
  USE BOUNDARY_CONDITIONS_ROUTINES
  USE CONSTANTS
  USE CONTROL_LOOP_ROUTINES
  USE DISTRIBUTED_MATRIX_VECTOR
  USE DOMAIN_MAPPINGS
  USE EQUATIONS_ROUTINES
  USE EQUATIONS_MAPPING_ROUTINES
  USE EQUATIONS_MATRICES_ROUTINES
  USE EQUATIONS_SET_CONSTANTS
  USE FIELD_ROUTINES
  USE FLUID_MECHANICS_IO_ROUTINES
  USE INPUT_OUTPUT
  USE ISO_VARYING_STRING
  USE KINDS
  USE MATRIX_VECTOR
  USE NODE_ROUTINES
  USE PROBLEM_CONSTANTS
  USE STRINGS
  USE SOLVER_ROUTINES
  USE TIMER
  USE TYPES

  IMPLICIT NONE

  PRIVATE

  PUBLIC NAVIER_STOKES_EQUATIONS_SET_SUBTYPE_SET
  PUBLIC NAVIER_STOKES_EQUATIONS_SET_SOLUTION_METHOD_SET
  PUBLIC NAVIER_STOKES_EQUATIONS_SET_SETUP

  PUBLIC NAVIER_STOKES_PROBLEM_SUBTYPE_SET
  PUBLIC NAVIER_STOKES_PROBLEM_SETUP

  PUBLIC NAVIER_STOKES_FINITE_ELEMENT_JACOBIAN_EVALUATE
  PUBLIC NAVIER_STOKES_FINITE_ELEMENT_RESIDUAL_EVALUATE
  PUBLIC NAVIER_STOKES_POST_SOLVE
  PUBLIC NAVIER_STOKES_PRE_SOLVE



CONTAINS 

!
!================================================================================================================================
!

  !>Sets/changes the solution method for a Navier-Stokes flow equation type of an fluid mechanics equations set class.
  SUBROUTINE NAVIER_STOKES_EQUATIONS_SET_SOLUTION_METHOD_SET(EQUATIONS_SET,SOLUTION_METHOD,ERR,ERROR,*)

    !Argument variables
    TYPE(EQUATIONS_SET_TYPE), POINTER :: EQUATIONS_SET !<A pointer to the equations set to set the solution method for
    INTEGER(INTG), INTENT(IN) :: SOLUTION_METHOD !<The solution method to set
    INTEGER(INTG), INTENT(OUT) :: ERR !<The error code
    TYPE(VARYING_STRING), INTENT(OUT) :: ERROR !<The error string
    !Local Variables
    TYPE(VARYING_STRING) :: LOCAL_ERROR
    
    CALL ENTERS("NAVIER_STOKES_EQUATIONS_SET_SOLUTION_METHOD_SET",ERR,ERROR,*999)
    
    IF(ASSOCIATED(EQUATIONS_SET)) THEN
      SELECT CASE(EQUATIONS_SET%SUBTYPE)
        CASE(EQUATIONS_SET_STATIC_NAVIER_STOKES_SUBTYPE, &
          & EQUATIONS_SET_LAPLACE_NAVIER_STOKES_SUBTYPE, &
          & EQUATIONS_SET_TRANSIENT_NAVIER_STOKES_SUBTYPE, &
          & EQUATIONS_SET_ALE_NAVIER_STOKES_SUBTYPE)                
          SELECT CASE(SOLUTION_METHOD)
            CASE(EQUATIONS_SET_FEM_SOLUTION_METHOD)
              EQUATIONS_SET%SOLUTION_METHOD=EQUATIONS_SET_FEM_SOLUTION_METHOD
            CASE(EQUATIONS_SET_BEM_SOLUTION_METHOD)
              CALL FLAG_ERROR("Not implemented.",ERR,ERROR,*999)
            CASE(EQUATIONS_SET_FD_SOLUTION_METHOD)
              CALL FLAG_ERROR("Not implemented.",ERR,ERROR,*999)
            CASE(EQUATIONS_SET_FV_SOLUTION_METHOD)
              CALL FLAG_ERROR("Not implemented.",ERR,ERROR,*999)
            CASE(EQUATIONS_SET_GFEM_SOLUTION_METHOD)
              CALL FLAG_ERROR("Not implemented.",ERR,ERROR,*999)
            CASE(EQUATIONS_SET_GFV_SOLUTION_METHOD)
              CALL FLAG_ERROR("Not implemented.",ERR,ERROR,*999)
            CASE DEFAULT
              LOCAL_ERROR="The specified solution method of "//TRIM(NUMBER_TO_VSTRING(SOLUTION_METHOD,"*",ERR,ERROR))// &
                & " is invalid."
              CALL FLAG_ERROR(LOCAL_ERROR,ERR,ERROR,*999)
          END SELECT
        CASE DEFAULT
          LOCAL_ERROR="Equations set subtype of "//TRIM(NUMBER_TO_VSTRING(EQUATIONS_SET%SUBTYPE,"*",ERR,ERROR))// &
            & " is not valid for a Navier-Stokes flow equation type of a fluid mechanics equations set class."
          CALL FLAG_ERROR(LOCAL_ERROR,ERR,ERROR,*999)
      END SELECT
    ELSE
      CALL FLAG_ERROR("Equations set is not associated.",ERR,ERROR,*999)
    ENDIF
       
    CALL EXITS("NAVIER_STOKES_EQUATIONS_SET_SOLUTION_METHOD_SET")
    RETURN
999 CALL ERRORS("NAVIER_STOKES_EQUATIONS_SET_SOLUTION_METHOD_SET",ERR,ERROR)
    CALL EXITS("NAVIER_STOKES_EQUATIONS_SET_SOLUTION_METHOD_SET")
    RETURN 1
  END SUBROUTINE NAVIER_STOKES_EQUATIONS_SET_SOLUTION_METHOD_SET

!
!================================================================================================================================
!

  !>Sets/changes the equation subtype for a Navier-Stokes fluid type of a fluid mechanics equations set class.
  SUBROUTINE NAVIER_STOKES_EQUATIONS_SET_SUBTYPE_SET(EQUATIONS_SET,EQUATIONS_SET_SUBTYPE,ERR,ERROR,*)

    !Argument variables
    TYPE(EQUATIONS_SET_TYPE), POINTER :: EQUATIONS_SET !<A pointer to the equations set to set the equation subtype for
    INTEGER(INTG), INTENT(IN) :: EQUATIONS_SET_SUBTYPE !<The equation subtype to set
    INTEGER(INTG), INTENT(OUT) :: ERR !<The error code
    TYPE(VARYING_STRING), INTENT(OUT) :: ERROR !<The error string
    !Local Variables
    TYPE(VARYING_STRING) :: LOCAL_ERROR

    CALL ENTERS("NAVIER_STOKES_EQUATIONS_SET_SUBTYPE_SET",ERR,ERROR,*999)

    IF(ASSOCIATED(EQUATIONS_SET)) THEN
      SELECT CASE(EQUATIONS_SET_SUBTYPE)
      CASE(EQUATIONS_SET_STATIC_NAVIER_STOKES_SUBTYPE)
        EQUATIONS_SET%CLASS=EQUATIONS_SET_FLUID_MECHANICS_CLASS
        EQUATIONS_SET%TYPE=EQUATIONS_SET_NAVIER_STOKES_EQUATION_TYPE
        EQUATIONS_SET%SUBTYPE=EQUATIONS_SET_STATIC_NAVIER_STOKES_SUBTYPE
      CASE(EQUATIONS_SET_LAPLACE_NAVIER_STOKES_SUBTYPE)
        EQUATIONS_SET%CLASS=EQUATIONS_SET_FLUID_MECHANICS_CLASS
        EQUATIONS_SET%TYPE=EQUATIONS_SET_NAVIER_STOKES_EQUATION_TYPE
        EQUATIONS_SET%SUBTYPE=EQUATIONS_SET_LAPLACE_NAVIER_STOKES_SUBTYPE
      CASE(EQUATIONS_SET_TRANSIENT_NAVIER_STOKES_SUBTYPE)
        EQUATIONS_SET%CLASS=EQUATIONS_SET_FLUID_MECHANICS_CLASS
        EQUATIONS_SET%TYPE=EQUATIONS_SET_NAVIER_STOKES_EQUATION_TYPE
        EQUATIONS_SET%SUBTYPE=EQUATIONS_SET_TRANSIENT_NAVIER_STOKES_SUBTYPE
      CASE(EQUATIONS_SET_ALE_STOKES_SUBTYPE)
        EQUATIONS_SET%CLASS=EQUATIONS_SET_FLUID_MECHANICS_CLASS
        EQUATIONS_SET%TYPE=EQUATIONS_SET_NAVIER_STOKES_EQUATION_TYPE
        EQUATIONS_SET%SUBTYPE=EQUATIONS_SET_ALE_NAVIER_STOKES_SUBTYPE
      CASE(EQUATIONS_SET_OPTIMISED_NAVIER_STOKES_SUBTYPE)
        CALL FLAG_ERROR("Not implemented yet.",ERR,ERROR,*999)
      CASE DEFAULT
        LOCAL_ERROR="Equations set subtype "//TRIM(NUMBER_TO_VSTRING(EQUATIONS_SET_SUBTYPE,"*",ERR,ERROR))// &
          & " is not valid for a Navier-Stokes fluid type of a fluid mechanics equations set class."
        CALL FLAG_ERROR(LOCAL_ERROR,ERR,ERROR,*999)
      END SELECT
    ELSE
      CALL FLAG_ERROR("Equations set is not associated.",ERR,ERROR,*999)
    ENDIF

    CALL EXITS("NAVIER_STOKES_EQUATIONS_SET_SUBTYPE_SET")
    RETURN
999 CALL ERRORS("NAVIER_STOKES_EQUATIONS_SET_SUBTYPE_SET",ERR,ERROR)
    CALL EXITS("NAVIER_STOKES_EQUATIONS_SET_SUBTYPE_SET")
    RETURN 1
  END SUBROUTINE NAVIER_STOKES_EQUATIONS_SET_SUBTYPE_SET

!
!================================================================================================================================
!

  !>Sets up the Navier-Stokes fluid setup.
  SUBROUTINE NAVIER_STOKES_EQUATIONS_SET_SETUP(EQUATIONS_SET,EQUATIONS_SET_SETUP,ERR,ERROR,*)

    !Argument variables
    TYPE(EQUATIONS_SET_TYPE), POINTER :: EQUATIONS_SET !<A pointer to the equations set to setup
    TYPE(EQUATIONS_SET_SETUP_TYPE), INTENT(INOUT) :: EQUATIONS_SET_SETUP !<The equations set setup information
    INTEGER(INTG), INTENT(OUT) :: ERR !<The error code
    TYPE(VARYING_STRING), INTENT(OUT) :: ERROR !<The error string
    !Local Variables
    INTEGER(INTG) :: GEOMETRIC_SCALING_TYPE,GEOMETRIC_MESH_COMPONENT
    TYPE(BOUNDARY_CONDITIONS_TYPE), POINTER :: BOUNDARY_CONDITIONS
    TYPE(DECOMPOSITION_TYPE), POINTER :: GEOMETRIC_DECOMPOSITION
    TYPE(EQUATIONS_TYPE), POINTER :: EQUATIONS
    TYPE(EQUATIONS_MAPPING_TYPE), POINTER :: EQUATIONS_MAPPING
    TYPE(EQUATIONS_MATRICES_TYPE), POINTER :: EQUATIONS_MATRICES
    TYPE(EQUATIONS_SET_MATERIALS_TYPE), POINTER :: EQUATIONS_MATERIALS
    TYPE(VARYING_STRING) :: LOCAL_ERROR
    INTEGER(INTG) :: DEPENDENT_FIELD_NUMBER_OF_VARIABLES,DEPENDENT_FIELD_NUMBER_OF_COMPONENTS
    INTEGER(INTG) :: NUMBER_OF_DIMENSIONS,GEOMETRIC_COMPONENT_NUMBER
    INTEGER(INTG) :: INDEPENDENT_FIELD_NUMBER_OF_COMPONENTS,INDEPENDENT_FIELD_NUMBER_OF_VARIABLES
    INTEGER(INTG) :: MATERIAL_FIELD_NUMBER_OF_VARIABLES,MATERIAL_FIELD_NUMBER_OF_COMPONENTS,I

    CALL ENTERS("NAVIER_STOKES_SET_SETUP",ERR,ERROR,*999)

    NULLIFY(EQUATIONS)
    NULLIFY(EQUATIONS_MAPPING)
    NULLIFY(EQUATIONS_MATRICES)
    NULLIFY(GEOMETRIC_DECOMPOSITION)
    NULLIFY(BOUNDARY_CONDITIONS)

    IF(ASSOCIATED(EQUATIONS_SET)) THEN

      SELECT CASE(EQUATIONS_SET%SUBTYPE)

!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
!!! NAVIER_STOKES SUBTYPES !!!
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

        CASE(EQUATIONS_SET_STATIC_NAVIER_STOKES_SUBTYPE, &
          & EQUATIONS_SET_TRANSIENT_NAVIER_STOKES_SUBTYPE, &
          & EQUATIONS_SET_LAPLACE_NAVIER_STOKES_SUBTYPE, &
          & EQUATIONS_SET_ALE_STOKES_SUBTYPE)

          SELECT CASE(EQUATIONS_SET_SETUP%SETUP_TYPE)
              
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
!!! SOLUTION METHOD !!!
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

            CASE(EQUATIONS_SET_SETUP_INITIAL_TYPE)
              SELECT CASE(EQUATIONS_SET%SUBTYPE)
                CASE(EQUATIONS_SET_STATIC_NAVIER_STOKES_SUBTYPE,EQUATIONS_SET_LAPLACE_NAVIER_STOKES_SUBTYPE, &
                  & EQUATIONS_SET_TRANSIENT_NAVIER_STOKES_SUBTYPE,EQUATIONS_SET_ALE_NAVIER_STOKES_SUBTYPE)
                  SELECT CASE(EQUATIONS_SET_SETUP%ACTION_TYPE)
                    CASE(EQUATIONS_SET_SETUP_START_ACTION)
                       CALL NAVIER_STOKES_EQUATIONS_SET_SOLUTION_METHOD_SET(EQUATIONS_SET, &
                        & EQUATIONS_SET_FEM_SOLUTION_METHOD,ERR,ERROR,*999)
                      EQUATIONS_SET%SOLUTION_METHOD=EQUATIONS_SET_FEM_SOLUTION_METHOD
                    CASE(EQUATIONS_SET_SETUP_FINISH_ACTION)
                      !!TODO: Check valid setup
                    CASE DEFAULT
                      LOCAL_ERROR="The action type of "//TRIM(NUMBER_TO_VSTRING(EQUATIONS_SET_SETUP%ACTION_TYPE, &
                        & "*",ERR,ERROR))// " for a setup type of "//TRIM(NUMBER_TO_VSTRING(EQUATIONS_SET_SETUP% &
                        & SETUP_TYPE,"*",ERR,ERROR))// " is not implemented for a Navier-Stokes fluid."
                      CALL FLAG_ERROR(LOCAL_ERROR,ERR,ERROR,*999)
                  END SELECT
                CASE DEFAULT
                  LOCAL_ERROR="The equation set subtype of "//TRIM(NUMBER_TO_VSTRING(EQUATIONS_SET%SUBTYPE,"*",ERR,ERROR))// &
                    & " for a setup sub type of "//TRIM(NUMBER_TO_VSTRING(EQUATIONS_SET%SUBTYPE,"*",ERR,ERROR))// &
                    & " is invalid for a Navier-Stokes equation."
                  CALL FLAG_ERROR(LOCAL_ERROR,ERR,ERROR,*999)
              END SELECT

!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
!!! GEOMETRY FIELD !!!
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

            CASE(EQUATIONS_SET_SETUP_GEOMETRY_TYPE)
              SELECT CASE(EQUATIONS_SET%SUBTYPE)
                CASE(EQUATIONS_SET_STATIC_NAVIER_STOKES_SUBTYPE,EQUATIONS_SET_LAPLACE_NAVIER_STOKES_SUBTYPE, &
                  & EQUATIONS_SET_TRANSIENT_NAVIER_STOKES_SUBTYPE,EQUATIONS_SET_ALE_NAVIER_STOKES_SUBTYPE)
                 !Do nothing???
                CASE DEFAULT
                  LOCAL_ERROR="The equation set subtype of "//TRIM(NUMBER_TO_VSTRING(EQUATIONS_SET%SUBTYPE,"*",ERR,ERROR))// &
                    & " is invalid for a Navier-Stokes equation."
                  CALL FLAG_ERROR(LOCAL_ERROR,ERR,ERROR,*999)
              END SELECT

!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
!!! DEPENDENT FIELD !!!
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

            CASE(EQUATIONS_SET_SETUP_DEPENDENT_TYPE)
              SELECT CASE(EQUATIONS_SET%SUBTYPE)
                CASE(EQUATIONS_SET_STATIC_NAVIER_STOKES_SUBTYPE,EQUATIONS_SET_LAPLACE_NAVIER_STOKES_SUBTYPE, &
                  & EQUATIONS_SET_TRANSIENT_NAVIER_STOKES_SUBTYPE,EQUATIONS_SET_ALE_NAVIER_STOKES_SUBTYPE)
                  SELECT CASE(EQUATIONS_SET_SETUP%ACTION_TYPE)
                    !Set start action
                    CASE(EQUATIONS_SET_SETUP_START_ACTION)
                      IF(EQUATIONS_SET%DEPENDENT%DEPENDENT_FIELD_AUTO_CREATED) THEN
                        !Create the auto created dependent field
                        !start field creation with name 'DEPENDENT_FIELD'
                        CALL FIELD_CREATE_START(EQUATIONS_SET_SETUP%FIELD_USER_NUMBER,EQUATIONS_SET%REGION, &
                          & EQUATIONS_SET%DEPENDENT%DEPENDENT_FIELD,ERR,ERROR,*999)
                        !start creation of a new field
                        CALL FIELD_TYPE_SET_AND_LOCK(EQUATIONS_SET%DEPENDENT%DEPENDENT_FIELD,FIELD_GENERAL_TYPE,ERR,ERROR,*999)
                        !define new created field to be dependent
                        CALL FIELD_DEPENDENT_TYPE_SET_AND_LOCK(EQUATIONS_SET%DEPENDENT%DEPENDENT_FIELD, &
                          & FIELD_DEPENDENT_TYPE,ERR,ERROR,*999)
                        !look for decomposition rule already defined
                        CALL FIELD_MESH_DECOMPOSITION_GET(EQUATIONS_SET%GEOMETRY%GEOMETRIC_FIELD,GEOMETRIC_DECOMPOSITION, &
                          & ERR,ERROR,*999)
                        !apply decomposition rule found on new created field
                        CALL FIELD_MESH_DECOMPOSITION_SET_AND_LOCK(EQUATIONS_SET%DEPENDENT%DEPENDENT_FIELD, &
                          & GEOMETRIC_DECOMPOSITION,ERR,ERROR,*999)
                        !point new field to geometric field
                        CALL FIELD_GEOMETRIC_FIELD_SET_AND_LOCK(EQUATIONS_SET%DEPENDENT%DEPENDENT_FIELD,EQUATIONS_SET%GEOMETRY% &
                          & GEOMETRIC_FIELD,ERR,ERROR,*999)
                        !set number of variables to 2 (1 for U and one for DELUDELN)
                        DEPENDENT_FIELD_NUMBER_OF_VARIABLES=2
                        CALL FIELD_NUMBER_OF_VARIABLES_SET_AND_LOCK(EQUATIONS_SET%DEPENDENT%DEPENDENT_FIELD, &
                          & DEPENDENT_FIELD_NUMBER_OF_VARIABLES,ERR,ERROR,*999)
                        CALL FIELD_VARIABLE_TYPES_SET_AND_LOCK(EQUATIONS_SET%DEPENDENT%DEPENDENT_FIELD,(/FIELD_U_VARIABLE_TYPE, &
                          & FIELD_DELUDELN_VARIABLE_TYPE/),ERR,ERROR,*999)
                        CALL FIELD_DIMENSION_SET_AND_LOCK(EQUATIONS_SET%DEPENDENT%DEPENDENT_FIELD,FIELD_U_VARIABLE_TYPE, &
                          & FIELD_VECTOR_DIMENSION_TYPE,ERR,ERROR,*999)
                        CALL FIELD_DIMENSION_SET_AND_LOCK(EQUATIONS_SET%DEPENDENT%DEPENDENT_FIELD,FIELD_DELUDELN_VARIABLE_TYPE, &
                          & FIELD_VECTOR_DIMENSION_TYPE,ERR,ERROR,*999)
                        CALL FIELD_DATA_TYPE_SET_AND_LOCK(EQUATIONS_SET%DEPENDENT%DEPENDENT_FIELD,FIELD_U_VARIABLE_TYPE, &
                          & FIELD_DP_TYPE,ERR,ERROR,*999)
                        CALL FIELD_DATA_TYPE_SET_AND_LOCK(EQUATIONS_SET%DEPENDENT%DEPENDENT_FIELD,FIELD_DELUDELN_VARIABLE_TYPE, &
                          & FIELD_DP_TYPE,ERR,ERROR,*999)
                        CALL FIELD_NUMBER_OF_COMPONENTS_GET(EQUATIONS_SET%GEOMETRY%GEOMETRIC_FIELD,FIELD_U_VARIABLE_TYPE, &
                          & NUMBER_OF_DIMENSIONS,ERR,ERROR,*999)

                        !calculate number of components with one component for each dimension and one for pressure
                        DEPENDENT_FIELD_NUMBER_OF_COMPONENTS=NUMBER_OF_DIMENSIONS+1
                        CALL FIELD_NUMBER_OF_COMPONENTS_SET_AND_LOCK(EQUATIONS_SET%DEPENDENT%DEPENDENT_FIELD, &
                          & FIELD_U_VARIABLE_TYPE,DEPENDENT_FIELD_NUMBER_OF_COMPONENTS,ERR,ERROR,*999)
                        CALL FIELD_NUMBER_OF_COMPONENTS_SET_AND_LOCK(EQUATIONS_SET%DEPENDENT%DEPENDENT_FIELD, &
                          & FIELD_DELUDELN_VARIABLE_TYPE,DEPENDENT_FIELD_NUMBER_OF_COMPONENTS,ERR,ERROR,*999)

                        CALL FIELD_COMPONENT_MESH_COMPONENT_GET(EQUATIONS_SET%GEOMETRY%GEOMETRIC_FIELD,FIELD_U_VARIABLE_TYPE, & 
                          & 1,GEOMETRIC_MESH_COMPONENT,ERR,ERROR,*999)
                        !Default to the geometric interpolation setup
                        DO I=1,DEPENDENT_FIELD_NUMBER_OF_COMPONENTS
                          CALL FIELD_COMPONENT_MESH_COMPONENT_SET(EQUATIONS_SET%DEPENDENT%DEPENDENT_FIELD, & 
                            & FIELD_U_VARIABLE_TYPE,I,GEOMETRIC_MESH_COMPONENT,ERR,ERROR,*999)
                          CALL FIELD_COMPONENT_MESH_COMPONENT_SET(EQUATIONS_SET%DEPENDENT%DEPENDENT_FIELD, &
                            & FIELD_DELUDELN_VARIABLE_TYPE,I,GEOMETRIC_MESH_COMPONENT,ERR,ERROR,*999)
                        END DO


                        SELECT CASE(EQUATIONS_SET%SOLUTION_METHOD)
                          !Specify fem solution method
                          CASE(EQUATIONS_SET_FEM_SOLUTION_METHOD)
                            DO I=1,DEPENDENT_FIELD_NUMBER_OF_COMPONENTS
                              CALL FIELD_COMPONENT_INTERPOLATION_SET_AND_LOCK(EQUATIONS_SET%DEPENDENT%DEPENDENT_FIELD, &
                                & FIELD_U_VARIABLE_TYPE,I,FIELD_NODE_BASED_INTERPOLATION,ERR,ERROR,*999)
                              CALL FIELD_COMPONENT_INTERPOLATION_SET_AND_LOCK(EQUATIONS_SET%DEPENDENT%DEPENDENT_FIELD, &
                                & FIELD_DELUDELN_VARIABLE_TYPE,I,FIELD_NODE_BASED_INTERPOLATION,ERR,ERROR,*999)
                            END DO
                            CALL FIELD_SCALING_TYPE_GET(EQUATIONS_SET%GEOMETRY%GEOMETRIC_FIELD,GEOMETRIC_SCALING_TYPE, &
                              & ERR,ERROR,*999)
                            CALL FIELD_SCALING_TYPE_SET(EQUATIONS_SET%DEPENDENT%DEPENDENT_FIELD,GEOMETRIC_SCALING_TYPE, &
                              & ERR,ERROR,*999)
                            !Other solutions not defined yet

                          CASE(EQUATIONS_SET_BEM_SOLUTION_METHOD)
                            CALL FLAG_ERROR("Not implemented.",ERR,ERROR,*999)
                          CASE(EQUATIONS_SET_FD_SOLUTION_METHOD)
                            CALL FLAG_ERROR("Not implemented.",ERR,ERROR,*999)
                          CASE(EQUATIONS_SET_FV_SOLUTION_METHOD)
                            CALL FLAG_ERROR("Not implemented.",ERR,ERROR,*999)
                          CASE(EQUATIONS_SET_GFEM_SOLUTION_METHOD)
                            CALL FLAG_ERROR("Not implemented.",ERR,ERROR,*999)
                          CASE(EQUATIONS_SET_GFV_SOLUTION_METHOD)
                            CALL FLAG_ERROR("Not implemented.",ERR,ERROR,*999)
                          CASE DEFAULT
                            LOCAL_ERROR="The solution method of " &
                              & //TRIM(NUMBER_TO_VSTRING(EQUATIONS_SET%SOLUTION_METHOD,"*",ERR,ERROR))// " is invalid."
                            CALL FLAG_ERROR(LOCAL_ERROR,ERR,ERROR,*999)
                        END SELECT
                      ELSE 
                        !Check the user specified field
                        CALL FIELD_TYPE_CHECK(EQUATIONS_SET_SETUP%FIELD,FIELD_GENERAL_TYPE,ERR,ERROR,*999)
                        CALL FIELD_DEPENDENT_TYPE_CHECK(EQUATIONS_SET_SETUP%FIELD,FIELD_DEPENDENT_TYPE,ERR,ERROR,*999)
                        CALL FIELD_NUMBER_OF_VARIABLES_CHECK(EQUATIONS_SET_SETUP%FIELD,2,ERR,ERROR,*999)
                        CALL FIELD_VARIABLE_TYPES_CHECK(EQUATIONS_SET_SETUP%FIELD,(/FIELD_U_VARIABLE_TYPE, &
                          & FIELD_DELUDELN_VARIABLE_TYPE/),ERR,ERROR,*999)
                        CALL FIELD_DIMENSION_CHECK(EQUATIONS_SET_SETUP%FIELD,FIELD_U_VARIABLE_TYPE, & 
                          & FIELD_VECTOR_DIMENSION_TYPE,ERR,ERROR,*999)
                        CALL FIELD_DIMENSION_CHECK(EQUATIONS_SET_SETUP%FIELD,FIELD_DELUDELN_VARIABLE_TYPE, &
                          & FIELD_VECTOR_DIMENSION_TYPE,ERR,ERROR,*999)
                        CALL FIELD_DATA_TYPE_CHECK(EQUATIONS_SET_SETUP%FIELD,FIELD_U_VARIABLE_TYPE,FIELD_DP_TYPE,ERR,ERROR,*999)
                        CALL FIELD_DATA_TYPE_CHECK(EQUATIONS_SET_SETUP%FIELD,FIELD_DELUDELN_VARIABLE_TYPE,FIELD_DP_TYPE, &
                          & ERR,ERROR,*999)
                        CALL FIELD_NUMBER_OF_COMPONENTS_GET(EQUATIONS_SET%GEOMETRY%GEOMETRIC_FIELD,FIELD_U_VARIABLE_TYPE, &
                          & NUMBER_OF_DIMENSIONS,ERR,ERROR,*999)
                        !calculate number of components with one component for each dimension and one for pressure
                        DEPENDENT_FIELD_NUMBER_OF_COMPONENTS=NUMBER_OF_DIMENSIONS+1
                        CALL FIELD_NUMBER_OF_COMPONENTS_CHECK(EQUATIONS_SET_SETUP%FIELD,FIELD_U_VARIABLE_TYPE, &
                          & DEPENDENT_FIELD_NUMBER_OF_COMPONENTS,ERR,ERROR,*999)
                        CALL FIELD_NUMBER_OF_COMPONENTS_CHECK(EQUATIONS_SET_SETUP%FIELD,FIELD_DELUDELN_VARIABLE_TYPE, &
                          & DEPENDENT_FIELD_NUMBER_OF_COMPONENTS,ERR,ERROR,*999)

                        SELECT CASE(EQUATIONS_SET%SOLUTION_METHOD)
                          CASE(EQUATIONS_SET_FEM_SOLUTION_METHOD)
                            CALL FIELD_COMPONENT_INTERPOLATION_CHECK(EQUATIONS_SET_SETUP%FIELD,FIELD_U_VARIABLE_TYPE,1, &
                              & FIELD_NODE_BASED_INTERPOLATION,ERR,ERROR,*999)
                            CALL FIELD_COMPONENT_INTERPOLATION_CHECK(EQUATIONS_SET_SETUP%FIELD,FIELD_DELUDELN_VARIABLE_TYPE,1, &
                              & FIELD_NODE_BASED_INTERPOLATION,ERR,ERROR,*999)

                          CASE(EQUATIONS_SET_BEM_SOLUTION_METHOD)
                            CALL FLAG_ERROR("Not implemented.",ERR,ERROR,*999)
                          CASE(EQUATIONS_SET_FD_SOLUTION_METHOD)
                            CALL FLAG_ERROR("Not implemented.",ERR,ERROR,*999)
                          CASE(EQUATIONS_SET_FV_SOLUTION_METHOD)
                            CALL FLAG_ERROR("Not implemented.",ERR,ERROR,*999)
                          CASE(EQUATIONS_SET_GFEM_SOLUTION_METHOD)
                            CALL FLAG_ERROR("Not implemented.",ERR,ERROR,*999)
                          CASE(EQUATIONS_SET_GFV_SOLUTION_METHOD)
                            CALL FLAG_ERROR("Not implemented.",ERR,ERROR,*999)
                          CASE DEFAULT
                            LOCAL_ERROR="The solution method of "//TRIM(NUMBER_TO_VSTRING(EQUATIONS_SET%SOLUTION_METHOD, &
                              & "*",ERR,ERROR))//" is invalid."
                            CALL FLAG_ERROR(LOCAL_ERROR,ERR,ERROR,*999)
                        END SELECT
                      ENDIF

                    !Specify finish action
                    CASE(EQUATIONS_SET_SETUP_FINISH_ACTION)
                      IF(EQUATIONS_SET%DEPENDENT%DEPENDENT_FIELD_AUTO_CREATED) THEN
                        CALL FIELD_CREATE_FINISH(EQUATIONS_SET%DEPENDENT%DEPENDENT_FIELD,ERR,ERROR,*999)
                      ENDIF
                    CASE DEFAULT
                      LOCAL_ERROR="The action type of "//TRIM(NUMBER_TO_VSTRING(EQUATIONS_SET_SETUP%ACTION_TYPE,"*", & 
                        & ERR,ERROR))//" for a setup type of "//TRIM(NUMBER_TO_VSTRING(EQUATIONS_SET_SETUP%SETUP_TYPE, & 
                        & "*",ERR,ERROR))//" is invalid for a Navier-Stokes fluid."
                      CALL FLAG_ERROR(LOCAL_ERROR,ERR,ERROR,*999)
                  END SELECT
                CASE DEFAULT
                  LOCAL_ERROR="The equation set subtype of "//TRIM(NUMBER_TO_VSTRING(EQUATIONS_SET%SUBTYPE,"*",ERR,ERROR))// &
                    & " for a setup sub type of "//TRIM(NUMBER_TO_VSTRING(EQUATIONS_SET%SUBTYPE,"*",ERR,ERROR))// &
                    & " is invalid for a Navier-Stokes equation."
                  CALL FLAG_ERROR(LOCAL_ERROR,ERR,ERROR,*999)
              END SELECT

          !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
          !!! INDEPENDENT FIELD FOR ALE!!!
          !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
  
            CASE(EQUATIONS_SET_SETUP_INDEPENDENT_TYPE)
              SELECT CASE(EQUATIONS_SET%SUBTYPE)
              CASE(EQUATIONS_SET_ALE_NAVIER_STOKES_SUBTYPE)
                  SELECT CASE(EQUATIONS_SET_SETUP%ACTION_TYPE)
                   !Set start action
                    CASE(EQUATIONS_SET_SETUP_START_ACTION)
                      IF(EQUATIONS_SET%INDEPENDENT%INDEPENDENT_FIELD_AUTO_CREATED) THEN
                        !Create the auto created independent field
                        !start field creation with name 'INDEPENDENT_FIELD'
                        CALL FIELD_CREATE_START(EQUATIONS_SET_SETUP%FIELD_USER_NUMBER,EQUATIONS_SET%REGION, &
                          & EQUATIONS_SET%INDEPENDENT%INDEPENDENT_FIELD,ERR,ERROR,*999)
                        !start creation of a new field
                        CALL FIELD_TYPE_SET_AND_LOCK(EQUATIONS_SET%INDEPENDENT%INDEPENDENT_FIELD,FIELD_GENERAL_TYPE,ERR,ERROR,*999)
                        !define new created field to be independent
                        CALL FIELD_DEPENDENT_TYPE_SET_AND_LOCK(EQUATIONS_SET%INDEPENDENT%INDEPENDENT_FIELD, &
                          & FIELD_INDEPENDENT_TYPE,ERR,ERROR,*999)
                        !look for decomposition rule already defined
                        CALL FIELD_MESH_DECOMPOSITION_GET(EQUATIONS_SET%GEOMETRY%GEOMETRIC_FIELD,GEOMETRIC_DECOMPOSITION, &
                          & ERR,ERROR,*999)
                        !apply decomposition rule found on new created field
                        CALL FIELD_MESH_DECOMPOSITION_SET_AND_LOCK(EQUATIONS_SET%INDEPENDENT%INDEPENDENT_FIELD, &
                          & GEOMETRIC_DECOMPOSITION,ERR,ERROR,*999)
                        !point new field to geometric field
                        CALL FIELD_GEOMETRIC_FIELD_SET_AND_LOCK(EQUATIONS_SET%INDEPENDENT%INDEPENDENT_FIELD,EQUATIONS_SET% & 
                          & GEOMETRY%GEOMETRIC_FIELD,ERR,ERROR,*999)
                        !set number of variables to 1 (1 for U)
                        INDEPENDENT_FIELD_NUMBER_OF_VARIABLES=1
                        CALL FIELD_NUMBER_OF_VARIABLES_SET_AND_LOCK(EQUATIONS_SET%INDEPENDENT%INDEPENDENT_FIELD, &
                        & INDEPENDENT_FIELD_NUMBER_OF_VARIABLES,ERR,ERROR,*999)
                        CALL FIELD_VARIABLE_TYPES_SET_AND_LOCK(EQUATIONS_SET%INDEPENDENT%INDEPENDENT_FIELD, & 
                          & (/FIELD_U_VARIABLE_TYPE/),ERR,ERROR,*999)
                        CALL FIELD_DIMENSION_SET_AND_LOCK(EQUATIONS_SET%INDEPENDENT%INDEPENDENT_FIELD,FIELD_U_VARIABLE_TYPE, &
                          & FIELD_VECTOR_DIMENSION_TYPE,ERR,ERROR,*999)
                        CALL FIELD_DATA_TYPE_SET_AND_LOCK(EQUATIONS_SET%INDEPENDENT%INDEPENDENT_FIELD,FIELD_U_VARIABLE_TYPE, &
                          & FIELD_DP_TYPE,ERR,ERROR,*999)
                        CALL FIELD_NUMBER_OF_COMPONENTS_GET(EQUATIONS_SET%GEOMETRY%GEOMETRIC_FIELD,FIELD_U_VARIABLE_TYPE, &
                          & NUMBER_OF_DIMENSIONS,ERR,ERROR,*999)
                        !calculate number of components with one component for each dimension
                        INDEPENDENT_FIELD_NUMBER_OF_COMPONENTS=NUMBER_OF_DIMENSIONS
                        CALL FIELD_NUMBER_OF_COMPONENTS_SET_AND_LOCK(EQUATIONS_SET%INDEPENDENT%INDEPENDENT_FIELD, & 
                          & FIELD_U_VARIABLE_TYPE,INDEPENDENT_FIELD_NUMBER_OF_COMPONENTS,ERR,ERROR,*999)
                        CALL FIELD_COMPONENT_MESH_COMPONENT_GET(EQUATIONS_SET%GEOMETRY%GEOMETRIC_FIELD,FIELD_U_VARIABLE_TYPE, & 
                          & 1,GEOMETRIC_MESH_COMPONENT,ERR,ERROR,*999)
                        !Default to the geometric interpolation setup
                        DO I=1,INDEPENDENT_FIELD_NUMBER_OF_COMPONENTS
                          CALL FIELD_COMPONENT_MESH_COMPONENT_SET(EQUATIONS_SET%INDEPENDENT%INDEPENDENT_FIELD, & 
                            & FIELD_U_VARIABLE_TYPE,I,GEOMETRIC_MESH_COMPONENT,ERR,ERROR,*999)
                        END DO

                        SELECT CASE(EQUATIONS_SET%SOLUTION_METHOD)
                          !Specify fem solution method
                          CASE(EQUATIONS_SET_FEM_SOLUTION_METHOD)
                            DO I=1,INDEPENDENT_FIELD_NUMBER_OF_COMPONENTS
                              CALL FIELD_COMPONENT_INTERPOLATION_SET_AND_LOCK(EQUATIONS_SET%INDEPENDENT%INDEPENDENT_FIELD, &
                              & FIELD_U_VARIABLE_TYPE,I,FIELD_NODE_BASED_INTERPOLATION,ERR,ERROR,*999)
                            END DO
                            CALL FIELD_SCALING_TYPE_GET(EQUATIONS_SET%GEOMETRY%GEOMETRIC_FIELD,GEOMETRIC_SCALING_TYPE, &
                              & ERR,ERROR,*999)
                            CALL FIELD_SCALING_TYPE_SET(EQUATIONS_SET%INDEPENDENT%INDEPENDENT_FIELD,GEOMETRIC_SCALING_TYPE, &
                              & ERR,ERROR,*999)
                            !Other solutions not defined yet
                          CASE DEFAULT
                            LOCAL_ERROR="The solution method of " &
                              & //TRIM(NUMBER_TO_VSTRING(EQUATIONS_SET%SOLUTION_METHOD,"*",ERR,ERROR))// " is invalid."
                            CALL FLAG_ERROR(LOCAL_ERROR,ERR,ERROR,*999)
                        END SELECT 

                      ELSE
                        !Check the user specified field
                        CALL FIELD_TYPE_CHECK(EQUATIONS_SET_SETUP%FIELD,FIELD_GENERAL_TYPE,ERR,ERROR,*999)
                        CALL FIELD_DEPENDENT_TYPE_CHECK(EQUATIONS_SET_SETUP%FIELD,FIELD_INDEPENDENT_TYPE,ERR,ERROR,*999)
                        CALL FIELD_NUMBER_OF_VARIABLES_CHECK(EQUATIONS_SET_SETUP%FIELD,1,ERR,ERROR,*999)
                        CALL FIELD_VARIABLE_TYPES_CHECK(EQUATIONS_SET_SETUP%FIELD,(/FIELD_U_VARIABLE_TYPE/),ERR,ERROR,*999)
                        CALL FIELD_DIMENSION_CHECK(EQUATIONS_SET_SETUP%FIELD,FIELD_U_VARIABLE_TYPE,FIELD_VECTOR_DIMENSION_TYPE, &
                          & ERR,ERROR,*999)
                        CALL FIELD_DATA_TYPE_CHECK(EQUATIONS_SET_SETUP%FIELD,FIELD_U_VARIABLE_TYPE,FIELD_DP_TYPE,ERR,ERROR,*999)
                        CALL FIELD_NUMBER_OF_COMPONENTS_GET(EQUATIONS_SET%GEOMETRY%GEOMETRIC_FIELD,FIELD_U_VARIABLE_TYPE, &
                          & NUMBER_OF_DIMENSIONS,ERR,ERROR,*999)
   
                        !calculate number of components with one component for each dimension and one for pressure
                        INDEPENDENT_FIELD_NUMBER_OF_COMPONENTS=NUMBER_OF_DIMENSIONS
                        CALL FIELD_NUMBER_OF_COMPONENTS_CHECK(EQUATIONS_SET_SETUP%FIELD,FIELD_U_VARIABLE_TYPE, &
                          & INDEPENDENT_FIELD_NUMBER_OF_COMPONENTS,ERR,ERROR,*999)
   
                        SELECT CASE(EQUATIONS_SET%SOLUTION_METHOD)
                          CASE(EQUATIONS_SET_FEM_SOLUTION_METHOD)
                            CALL FIELD_COMPONENT_INTERPOLATION_CHECK(EQUATIONS_SET_SETUP%FIELD,FIELD_U_VARIABLE_TYPE,1, &
                              & FIELD_NODE_BASED_INTERPOLATION,ERR,ERROR,*999)
                            CALL FIELD_COMPONENT_INTERPOLATION_CHECK(EQUATIONS_SET_SETUP%FIELD,FIELD_DELUDELN_VARIABLE_TYPE,1, &
                              & FIELD_NODE_BASED_INTERPOLATION,ERR,ERROR,*999)
                          CASE DEFAULT
                            LOCAL_ERROR="The solution method of "//TRIM(NUMBER_TO_VSTRING(EQUATIONS_SET%SOLUTION_METHOD, &
                              &"*",ERR,ERROR))//" is invalid."
                             CALL FLAG_ERROR(LOCAL_ERROR,ERR,ERROR,*999)
                        END SELECT

                      ENDIF    
 
                    !Specify finish action
                    CASE(EQUATIONS_SET_SETUP_FINISH_ACTION)
                      IF(EQUATIONS_SET%INDEPENDENT%INDEPENDENT_FIELD_AUTO_CREATED) THEN
                        CALL FIELD_CREATE_FINISH(EQUATIONS_SET%INDEPENDENT%INDEPENDENT_FIELD,ERR,ERROR,*999)
                        CALL FIELD_PARAMETER_SET_CREATE(EQUATIONS_SET%INDEPENDENT%INDEPENDENT_FIELD,FIELD_U_VARIABLE_TYPE, &
                           & FIELD_MESH_DISPLACEMENT_SET_TYPE,ERR,ERROR,*999)
                        CALL FIELD_PARAMETER_SET_CREATE(EQUATIONS_SET%INDEPENDENT%INDEPENDENT_FIELD,FIELD_U_VARIABLE_TYPE, &
                           & FIELD_MESH_VELOCITY_SET_TYPE,ERR,ERROR,*999)
                        CALL FIELD_PARAMETER_SET_CREATE(EQUATIONS_SET%INDEPENDENT%INDEPENDENT_FIELD,FIELD_U_VARIABLE_TYPE, &
                          & FIELD_BOUNDARY_SET_TYPE,ERR,ERROR,*999)
                      ENDIF
        
                    CASE DEFAULT
                      LOCAL_ERROR="The action type of "//TRIM(NUMBER_TO_VSTRING(EQUATIONS_SET_SETUP%ACTION_TYPE,"*",ERR,ERROR))// &
                      & " for a setup type of "//TRIM(NUMBER_TO_VSTRING(EQUATIONS_SET_SETUP%SETUP_TYPE,"*",ERR,ERROR))// &
                      & " is invalid for a standard Navier-Stokes fluid"
                      CALL FLAG_ERROR(LOCAL_ERROR,ERR,ERROR,*999)
                  END SELECT
                CASE DEFAULT
                  LOCAL_ERROR="The equation set subtype of "//TRIM(NUMBER_TO_VSTRING(EQUATIONS_SET%SUBTYPE,"*",ERR,ERROR))// &
                    & " for a setup sub type of "//TRIM(NUMBER_TO_VSTRING(EQUATIONS_SET%SUBTYPE,"*",ERR,ERROR))// &
                    & " is invalid for a Navier-Stokes equation."
                   CALL FLAG_ERROR(LOCAL_ERROR,ERR,ERROR,*999)
              END SELECT

!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
!!! MATERIALS FIELD !!!
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

            CASE(EQUATIONS_SET_SETUP_MATERIALS_TYPE)
              SELECT CASE(EQUATIONS_SET%SUBTYPE)
                CASE(EQUATIONS_SET_STATIC_NAVIER_STOKES_SUBTYPE,EQUATIONS_SET_LAPLACE_NAVIER_STOKES_SUBTYPE, &
                  & EQUATIONS_SET_TRANSIENT_NAVIER_STOKES_SUBTYPE,EQUATIONS_SET_ALE_NAVIER_STOKES_SUBTYPE)
      
                  !variable X with has Y components, here Y represents viscosity only
                  MATERIAL_FIELD_NUMBER_OF_VARIABLES=1!X
                  MATERIAL_FIELD_NUMBER_OF_COMPONENTS=2!Y

                  SELECT CASE(EQUATIONS_SET_SETUP%ACTION_TYPE)
                    !Specify start action
                    CASE(EQUATIONS_SET_SETUP_START_ACTION)
                      EQUATIONS_MATERIALS=>EQUATIONS_SET%MATERIALS
                      IF(ASSOCIATED(EQUATIONS_MATERIALS)) THEN
                        IF(EQUATIONS_MATERIALS%MATERIALS_FIELD_AUTO_CREATED) THEN
                          !Create the auto created materials field
                          !start field creation with name 'MATERIAL_FIELD'
                          CALL FIELD_CREATE_START(EQUATIONS_SET_SETUP%FIELD_USER_NUMBER,EQUATIONS_SET%REGION, & 
                            & EQUATIONS_SET%MATERIALS%MATERIALS_FIELD,ERR,ERROR,*999)
                          CALL FIELD_TYPE_SET_AND_LOCK(EQUATIONS_MATERIALS%MATERIALS_FIELD,FIELD_MATERIAL_TYPE,ERR,ERROR,*999)
                          CALL FIELD_DEPENDENT_TYPE_SET_AND_LOCK(EQUATIONS_MATERIALS%MATERIALS_FIELD,FIELD_INDEPENDENT_TYPE, &
                            & ERR,ERROR,*999)
                          CALL FIELD_MESH_DECOMPOSITION_GET(EQUATIONS_SET%GEOMETRY%GEOMETRIC_FIELD,GEOMETRIC_DECOMPOSITION, & 
                            & ERR,ERROR,*999)
                          !apply decomposition rule found on new created field
                          CALL FIELD_MESH_DECOMPOSITION_SET_AND_LOCK(EQUATIONS_SET%MATERIALS%MATERIALS_FIELD, & 
                            & GEOMETRIC_DECOMPOSITION,ERR,ERROR,*999)
                          !point new field to geometric field
                          CALL FIELD_GEOMETRIC_FIELD_SET_AND_LOCK(EQUATIONS_MATERIALS%MATERIALS_FIELD,EQUATIONS_SET%GEOMETRY% &
                            & GEOMETRIC_FIELD,ERR,ERROR,*999)
                          CALL FIELD_NUMBER_OF_VARIABLES_SET(EQUATIONS_MATERIALS%MATERIALS_FIELD, & 
                            & MATERIAL_FIELD_NUMBER_OF_VARIABLES,ERR,ERROR,*999)
                          CALL FIELD_VARIABLE_TYPES_SET_AND_LOCK(EQUATIONS_MATERIALS%MATERIALS_FIELD, & 
                            &(/FIELD_U_VARIABLE_TYPE/),ERR,ERROR,*999)
                          CALL FIELD_DIMENSION_SET_AND_LOCK(EQUATIONS_MATERIALS%MATERIALS_FIELD,FIELD_U_VARIABLE_TYPE, &
                            & FIELD_VECTOR_DIMENSION_TYPE,ERR,ERROR,*999)
                          CALL FIELD_DATA_TYPE_SET_AND_LOCK(EQUATIONS_MATERIALS%MATERIALS_FIELD,FIELD_U_VARIABLE_TYPE, &
                            & FIELD_DP_TYPE,ERR,ERROR,*999)
                          CALL FIELD_NUMBER_OF_COMPONENTS_SET_AND_LOCK(EQUATIONS_MATERIALS%MATERIALS_FIELD, & 
                            & FIELD_U_VARIABLE_TYPE,MATERIAL_FIELD_NUMBER_OF_COMPONENTS,ERR,ERROR,*999)
                          CALL FIELD_COMPONENT_MESH_COMPONENT_GET(EQUATIONS_SET%GEOMETRY%GEOMETRIC_FIELD, & 
                            & FIELD_U_VARIABLE_TYPE,1,GEOMETRIC_COMPONENT_NUMBER,ERR,ERROR,*999)
                          CALL FIELD_COMPONENT_MESH_COMPONENT_SET(EQUATIONS_MATERIALS%MATERIALS_FIELD,FIELD_U_VARIABLE_TYPE, &
                            & 1,GEOMETRIC_COMPONENT_NUMBER,ERR,ERROR,*999)
                          CALL FIELD_COMPONENT_INTERPOLATION_SET(EQUATIONS_MATERIALS%MATERIALS_FIELD,FIELD_U_VARIABLE_TYPE, &
                            & 1,FIELD_CONSTANT_INTERPOLATION,ERR,ERROR,*999)
                          !Default the field scaling to that of the geometric field
                          CALL FIELD_SCALING_TYPE_GET(EQUATIONS_SET%GEOMETRY%GEOMETRIC_FIELD,GEOMETRIC_SCALING_TYPE, & 
                            & ERR,ERROR,*999)
                          CALL FIELD_SCALING_TYPE_SET(EQUATIONS_MATERIALS%MATERIALS_FIELD,GEOMETRIC_SCALING_TYPE,ERR,ERROR,*999)
                       ELSE
                          !Check the user specified field
                          CALL FIELD_TYPE_CHECK(EQUATIONS_SET_SETUP%FIELD,FIELD_MATERIAL_TYPE,ERR,ERROR,*999)
                          CALL FIELD_DEPENDENT_TYPE_CHECK(EQUATIONS_SET_SETUP%FIELD,FIELD_INDEPENDENT_TYPE,ERR,ERROR,*999)
                          CALL FIELD_NUMBER_OF_VARIABLES_CHECK(EQUATIONS_SET_SETUP%FIELD,1,ERR,ERROR,*999)
                          CALL FIELD_VARIABLE_TYPES_CHECK(EQUATIONS_SET_SETUP%FIELD,(/FIELD_U_VARIABLE_TYPE/),ERR,ERROR,*999)
                          CALL FIELD_DIMENSION_CHECK(EQUATIONS_SET_SETUP%FIELD,FIELD_U_VARIABLE_TYPE, & 
                            & FIELD_VECTOR_DIMENSION_TYPE,ERR,ERROR,*999)
                          CALL FIELD_DATA_TYPE_CHECK(EQUATIONS_SET_SETUP%FIELD,FIELD_U_VARIABLE_TYPE,FIELD_DP_TYPE, & 
                            & ERR,ERROR,*999)
                          CALL FIELD_NUMBER_OF_COMPONENTS_GET(EQUATIONS_SET%GEOMETRY%GEOMETRIC_FIELD,FIELD_U_VARIABLE_TYPE, &
                            & NUMBER_OF_DIMENSIONS,ERR,ERROR,*999)
                          CALL FIELD_NUMBER_OF_COMPONENTS_CHECK(EQUATIONS_SET_SETUP%FIELD,FIELD_U_VARIABLE_TYPE,1,ERR,ERROR,*999)
                        ENDIF
                      ELSE
                        CALL FLAG_ERROR("Equations set materials is not associated.",ERR,ERROR,*999)
                      END IF

                    !Specify start action
                    CASE(EQUATIONS_SET_SETUP_FINISH_ACTION)
                      EQUATIONS_MATERIALS=>EQUATIONS_SET%MATERIALS
                        IF(ASSOCIATED(EQUATIONS_MATERIALS)) THEN
                          IF(EQUATIONS_MATERIALS%MATERIALS_FIELD_AUTO_CREATED) THEN
                            !Finish creating the materials field
                              CALL FIELD_CREATE_FINISH(EQUATIONS_MATERIALS%MATERIALS_FIELD,ERR,ERROR,*999)
                              !Set the default values for the materials field
                              !First set the mu values to 0.001
                              !MATERIAL_FIELD_NUMBER_OF_COMPONENTS
                              ! viscosity=1
                              CALL FIELD_COMPONENT_VALUES_INITIALISE(EQUATIONS_MATERIALS%MATERIALS_FIELD,FIELD_U_VARIABLE_TYPE, &
                                & FIELD_VALUES_SET_TYPE,1,1.0_DP,ERR,ERROR,*999)
                              ! density=2
                              CALL FIELD_COMPONENT_VALUES_INITIALISE(EQUATIONS_MATERIALS%MATERIALS_FIELD,FIELD_U_VARIABLE_TYPE, &
                                & FIELD_VALUES_SET_TYPE,2,1.0_DP,ERR,ERROR,*999)
                            ENDIF
                          ELSE
                            CALL FLAG_ERROR("Equations set materials is not associated.",ERR,ERROR,*999)
                          ENDIF

                    CASE DEFAULT
                      LOCAL_ERROR="The action type of "//TRIM(NUMBER_TO_VSTRING(EQUATIONS_SET_SETUP%ACTION_TYPE,"*", & 
                        & ERR,ERROR))//" for a setup type of "//TRIM(NUMBER_TO_VSTRING(EQUATIONS_SET_SETUP%SETUP_TYPE,"*", & 
                        & ERR,ERROR))//" is invalid for Navier-Stokes equation."
                      CALL FLAG_ERROR(LOCAL_ERROR,ERR,ERROR,*999)
                  END SELECT

                CASE DEFAULT
                  LOCAL_ERROR="The equation set subtype of "//TRIM(NUMBER_TO_VSTRING(EQUATIONS_SET%SUBTYPE,"*",ERR,ERROR))// &
                    & " for a setup sub type of "//TRIM(NUMBER_TO_VSTRING(EQUATIONS_SET%SUBTYPE,"*",ERR,ERROR))// &
                    & " is invalid for a Navier-Stokes equation."
                  CALL FLAG_ERROR(LOCAL_ERROR,ERR,ERROR,*999)
              END SELECT

!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
!!! SOURCE TYPE !!!
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

            CASE(EQUATIONS_SET_SETUP_SOURCE_TYPE)
              SELECT CASE(EQUATIONS_SET%SUBTYPE)
                CASE(EQUATIONS_SET_STATIC_NAVIER_STOKES_SUBTYPE,EQUATIONS_SET_LAPLACE_NAVIER_STOKES_SUBTYPE, &
                  & EQUATIONS_SET_TRANSIENT_NAVIER_STOKES_SUBTYPE,EQUATIONS_SET_ALE_NAVIER_STOKES_SUBTYPE)
                !TO DO: INCLUDE GRAVITY AS SOURCE TYPE

                  SELECT CASE(EQUATIONS_SET_SETUP%ACTION_TYPE)
                    CASE(EQUATIONS_SET_SETUP_START_ACTION)
                      !Do nothing
                    CASE(EQUATIONS_SET_SETUP_FINISH_ACTION)
                      !Do nothing
                      !? Maybe set finished flag????
                    CASE DEFAULT
                      LOCAL_ERROR="The action type of "//TRIM(NUMBER_TO_VSTRING(EQUATIONS_SET_SETUP%ACTION_TYPE,"*", &
                        & ERR,ERROR))//" for a setup type of "//TRIM(NUMBER_TO_VSTRING(EQUATIONS_SET_SETUP%SETUP_TYPE,"*", & 
                        & ERR,ERROR))//" is invalid for a Navier-Stokes fluid."
                      CALL FLAG_ERROR(LOCAL_ERROR,ERR,ERROR,*999)
                  END SELECT

                CASE DEFAULT
                  LOCAL_ERROR="The equation set subtype of "//TRIM(NUMBER_TO_VSTRING(EQUATIONS_SET%SUBTYPE,"*",ERR,ERROR))// &
                    &  " for a setup sub type of "//TRIM(NUMBER_TO_VSTRING(EQUATIONS_SET%SUBTYPE,"*",ERR,ERROR))// &
                    &  " is invalid for a Navier-Stokes equation."
                  CALL FLAG_ERROR(LOCAL_ERROR,ERR,ERROR,*999)
              END SELECT

!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
!!! EQUATIONS_TYPE !!!
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

            CASE(EQUATIONS_SET_SETUP_EQUATIONS_TYPE)
              SELECT CASE(EQUATIONS_SET%SUBTYPE)
                CASE(EQUATIONS_SET_STATIC_NAVIER_STOKES_SUBTYPE,EQUATIONS_SET_LAPLACE_NAVIER_STOKES_SUBTYPE)
                  SELECT CASE(EQUATIONS_SET_SETUP%ACTION_TYPE)
                    CASE(EQUATIONS_SET_SETUP_START_ACTION)
                      EQUATIONS_MATERIALS=>EQUATIONS_SET%MATERIALS
                      IF(ASSOCIATED(EQUATIONS_MATERIALS)) THEN              
                        IF(EQUATIONS_MATERIALS%MATERIALS_FINISHED) THEN
                          CALL EQUATIONS_CREATE_START(EQUATIONS_SET,EQUATIONS,ERR,ERROR,*999)
                          CALL EQUATIONS_LINEARITY_TYPE_SET(EQUATIONS,EQUATIONS_NONLINEAR,ERR,ERROR,*999)
                          CALL EQUATIONS_TIME_DEPENDENCE_TYPE_SET(EQUATIONS,EQUATIONS_STATIC,ERR,ERROR,*999)
                        ELSE
                          CALL FLAG_ERROR("Equations set materials has not been finished.",ERR,ERROR,*999)
                        ENDIF
                      ELSE
                        CALL FLAG_ERROR("Equations materials is not associated.",ERR,ERROR,*999)
                      ENDIF
                    CASE(EQUATIONS_SET_SETUP_FINISH_ACTION)
                      SELECT CASE(EQUATIONS_SET%SOLUTION_METHOD)
                        CASE(EQUATIONS_SET_FEM_SOLUTION_METHOD)
                          !Finish the creation of the equations
                          CALL EQUATIONS_SET_EQUATIONS_GET(EQUATIONS_SET,EQUATIONS,ERR,ERROR,*999)
                          CALL EQUATIONS_CREATE_FINISH(EQUATIONS,ERR,ERROR,*999)
                          !Create the equations mapping.
                          CALL EQUATIONS_MAPPING_CREATE_START(EQUATIONS,EQUATIONS_MAPPING,ERR,ERROR,*999)
                          CALL EQUATIONS_MAPPING_LINEAR_MATRICES_NUMBER_SET(EQUATIONS_MAPPING,1,ERR,ERROR,*999)
                          CALL EQUATIONS_MAPPING_LINEAR_MATRICES_VARIABLE_TYPES_SET(EQUATIONS_MAPPING,(/FIELD_U_VARIABLE_TYPE/), &
                            & ERR,ERROR,*999)
!                          CALL EQUATIONS_MAPPING_RESIDUAL_VARIABLE_TYPE_SET(EQUATIONS_MAPPING,FIELD_U_VARIABLE_TYPE,ERR,ERROR,*999)
                          CALL EQUATIONS_MAPPING_RHS_VARIABLE_TYPE_SET(EQUATIONS_MAPPING,FIELD_DELUDELN_VARIABLE_TYPE, & 
                            & ERR,ERROR,*999)
                          CALL EQUATIONS_MAPPING_CREATE_FINISH(EQUATIONS_MAPPING,ERR,ERROR,*999)
                          !Create the equations matrices
                          CALL EQUATIONS_MATRICES_CREATE_START(EQUATIONS,EQUATIONS_MATRICES,ERR,ERROR,*999)
                          SELECT CASE(EQUATIONS%SPARSITY_TYPE)
                            CASE(EQUATIONS_MATRICES_FULL_MATRICES)
                              CALL EQUATIONS_MATRICES_LINEAR_STORAGE_TYPE_SET(EQUATIONS_MATRICES,(/MATRIX_BLOCK_STORAGE_TYPE/), &
                                & ERR,ERROR,*999)
                              CALL EQUATIONS_MATRICES_NONLINEAR_STORAGE_TYPE_SET(EQUATIONS_MATRICES,MATRIX_BLOCK_STORAGE_TYPE, &
                                & ERR,ERROR,*999)
                            CASE(EQUATIONS_MATRICES_SPARSE_MATRICES)
                              CALL EQUATIONS_MATRICES_LINEAR_STORAGE_TYPE_SET(EQUATIONS_MATRICES, & 
                                & (/MATRIX_COMPRESSED_ROW_STORAGE_TYPE/),ERR,ERROR,*999)
                              CALL EQUATIONS_MATRICES_NONLINEAR_STORAGE_TYPE_SET(EQUATIONS_MATRICES, & 
                                & MATRIX_COMPRESSED_ROW_STORAGE_TYPE,ERR,ERROR,*999)
                              CALL EQUATIONS_MATRICES_LINEAR_STRUCTURE_TYPE_SET(EQUATIONS_MATRICES, & 
                                & (/EQUATIONS_MATRIX_FEM_STRUCTURE/),ERR,ERROR,*999)
                              CALL EQUATIONS_MATRICES_NONLINEAR_STRUCTURE_TYPE_SET(EQUATIONS_MATRICES, & 
                                & EQUATIONS_MATRIX_FEM_STRUCTURE,ERR,ERROR,*999)
                            CASE DEFAULT
                              LOCAL_ERROR="The equations matrices sparsity type of "// &
                                & TRIM(NUMBER_TO_VSTRING(EQUATIONS%SPARSITY_TYPE,"*",ERR,ERROR))//" is invalid."
                              CALL FLAG_ERROR(LOCAL_ERROR,ERR,ERROR,*999)
                          END SELECT
                          CALL EQUATIONS_MATRICES_CREATE_FINISH(EQUATIONS_MATRICES,ERR,ERROR,*999)
                        CASE(EQUATIONS_SET_BEM_SOLUTION_METHOD)
                          CALL FLAG_ERROR("Not implemented.",ERR,ERROR,*999)
                        CASE(EQUATIONS_SET_FD_SOLUTION_METHOD)
                          CALL FLAG_ERROR("Not implemented.",ERR,ERROR,*999)
                        CASE(EQUATIONS_SET_FV_SOLUTION_METHOD)
                          CALL FLAG_ERROR("Not implemented.",ERR,ERROR,*999)
                        CASE(EQUATIONS_SET_GFEM_SOLUTION_METHOD)
                          CALL FLAG_ERROR("Not implemented.",ERR,ERROR,*999)
                        CASE(EQUATIONS_SET_GFV_SOLUTION_METHOD)
                          CALL FLAG_ERROR("Not implemented.",ERR,ERROR,*999)
                        CASE DEFAULT
                          LOCAL_ERROR="The solution method of "//TRIM(NUMBER_TO_VSTRING(EQUATIONS_SET%SOLUTION_METHOD, &
                            & "*",ERR,ERROR))//" is invalid."
                          CALL FLAG_ERROR(LOCAL_ERROR,ERR,ERROR,*999)
                      END SELECT
                    CASE DEFAULT
                      LOCAL_ERROR="The action type of "//TRIM(NUMBER_TO_VSTRING(EQUATIONS_SET_SETUP%ACTION_TYPE,"*",ERR,ERROR))// &
                        & " for a setup type of "//TRIM(NUMBER_TO_VSTRING(EQUATIONS_SET_SETUP%SETUP_TYPE,"*",ERR,ERROR))// &
                        & " is invalid for a steady Laplace equation."
                      CALL FLAG_ERROR(LOCAL_ERROR,ERR,ERROR,*999)
                  END SELECT
                CASE(EQUATIONS_SET_TRANSIENT_NAVIER_STOKES_SUBTYPE,EQUATIONS_SET_ALE_NAVIER_STOKES_SUBTYPE)
                  SELECT CASE(EQUATIONS_SET_SETUP%ACTION_TYPE)
                    CASE(EQUATIONS_SET_SETUP_START_ACTION)
                      EQUATIONS_MATERIALS=>EQUATIONS_SET%MATERIALS
                      IF(ASSOCIATED(EQUATIONS_MATERIALS)) THEN              
                        IF(EQUATIONS_MATERIALS%MATERIALS_FINISHED) THEN
                          CALL EQUATIONS_CREATE_START(EQUATIONS_SET,EQUATIONS,ERR,ERROR,*999)
                          CALL EQUATIONS_LINEARITY_TYPE_SET(EQUATIONS,EQUATIONS_NONLINEAR,ERR,ERROR,*999)
                          CALL EQUATIONS_TIME_DEPENDENCE_TYPE_SET(EQUATIONS,EQUATIONS_FIRST_ORDER_DYNAMIC,ERR,ERROR,*999)
                        ELSE
                          CALL FLAG_ERROR("Equations set materials has not been finished.",ERR,ERROR,*999)
                        ENDIF
                      ELSE
                        CALL FLAG_ERROR("Equations materials is not associated.",ERR,ERROR,*999)
                      ENDIF
                    CASE(EQUATIONS_SET_SETUP_FINISH_ACTION)
                      SELECT CASE(EQUATIONS_SET%SOLUTION_METHOD)
                        CASE(EQUATIONS_SET_FEM_SOLUTION_METHOD)
                          !Finish the creation of the equations
                          CALL EQUATIONS_SET_EQUATIONS_GET(EQUATIONS_SET,EQUATIONS,ERR,ERROR,*999)
                          CALL EQUATIONS_CREATE_FINISH(EQUATIONS,ERR,ERROR,*999)
                          !Create the equations mapping.
                          CALL EQUATIONS_MAPPING_CREATE_START(EQUATIONS,EQUATIONS_MAPPING,ERR,ERROR,*999)
!                          CALL EQUATIONS_MAPPING_LINEAR_MATRICES_NUMBER_SET(EQUATIONS_MAPPING,1,ERR,ERROR,*999)
!                          CALL EQUATIONS_MAPPING_LINEAR_MATRICES_VARIABLE_TYPES_SET(EQUATIONS_MAPPING,(/FIELD_U_VARIABLE_TYPE/), &
!                            & ERR,ERROR,*999)
                          CALL EQUATIONS_MAPPING_RESIDUAL_VARIABLE_TYPE_SET(EQUATIONS_MAPPING,FIELD_U_VARIABLE_TYPE,ERR,ERROR,*999)
                          CALL EQUATIONS_MAPPING_DYNAMIC_MATRICES_SET(EQUATIONS_MAPPING,.TRUE.,.TRUE.,ERR,ERROR,*999)
                          CALL EQUATIONS_MAPPING_DYNAMIC_VARIABLE_TYPE_SET(EQUATIONS_MAPPING,FIELD_U_VARIABLE_TYPE,ERR,ERROR,*999)
                          CALL EQUATIONS_MAPPING_RHS_VARIABLE_TYPE_SET(EQUATIONS_MAPPING,FIELD_DELUDELN_VARIABLE_TYPE,ERR, & 
                            & ERROR,*999)
                          CALL EQUATIONS_MAPPING_RESIDUAL_VARIABLE_TYPE_SET(EQUATIONS_MAPPING,FIELD_U_VARIABLE_TYPE,ERR,ERROR,*999)
                          CALL EQUATIONS_MAPPING_CREATE_FINISH(EQUATIONS_MAPPING,ERR,ERROR,*999)
                          !Create the equations matrices
                          CALL EQUATIONS_MATRICES_CREATE_START(EQUATIONS,EQUATIONS_MATRICES,ERR,ERROR,*999)
                          SELECT CASE(EQUATIONS%SPARSITY_TYPE)
                            CASE(EQUATIONS_MATRICES_FULL_MATRICES)
                              CALL EQUATIONS_MATRICES_DYNAMIC_STORAGE_TYPE_SET(EQUATIONS_MATRICES,(/MATRIX_BLOCK_STORAGE_TYPE/), &
                                & ERR,ERROR,*999)
                              CALL EQUATIONS_MATRICES_NONLINEAR_STORAGE_TYPE_SET(EQUATIONS_MATRICES,MATRIX_BLOCK_STORAGE_TYPE, &
                                & ERR,ERROR,*999)
                            CASE(EQUATIONS_MATRICES_SPARSE_MATRICES)
                              CALL EQUATIONS_MATRICES_DYNAMIC_STORAGE_TYPE_SET(EQUATIONS_MATRICES, &
                                & (/DISTRIBUTED_MATRIX_COMPRESSED_ROW_STORAGE_TYPE, & 
                                & DISTRIBUTED_MATRIX_COMPRESSED_ROW_STORAGE_TYPE/),ERR,ERROR,*999)
                              CALL EQUATIONS_MATRICES_DYNAMIC_STRUCTURE_TYPE_SET(EQUATIONS_MATRICES, &
                                & (/EQUATIONS_MATRIX_FEM_STRUCTURE,EQUATIONS_MATRIX_FEM_STRUCTURE/),ERR,ERROR,*999)
!                               CALL EQUATIONS_MATRICES_LINEAR_STORAGE_TYPE_SET(EQUATIONS_MATRICES, & 
!                                 & (/MATRIX_COMPRESSED_ROW_STORAGE_TYPE/),ERR,ERROR,*999)
                              CALL EQUATIONS_MATRICES_NONLINEAR_STORAGE_TYPE_SET(EQUATIONS_MATRICES, & 
                                & MATRIX_COMPRESSED_ROW_STORAGE_TYPE,ERR,ERROR,*999)
!                               CALL EQUATIONS_MATRICES_LINEAR_STRUCTURE_TYPE_SET(EQUATIONS_MATRICES, & 
!                                 & (/EQUATIONS_MATRIX_FEM_STRUCTURE/),ERR,ERROR,*999)
                              CALL EQUATIONS_MATRICES_NONLINEAR_STRUCTURE_TYPE_SET(EQUATIONS_MATRICES, & 
                                & EQUATIONS_MATRIX_FEM_STRUCTURE,ERR,ERROR,*999)
                            CASE DEFAULT
                              LOCAL_ERROR="The equations matrices sparsity type of "// &
                                & TRIM(NUMBER_TO_VSTRING(EQUATIONS%SPARSITY_TYPE,"*",ERR,ERROR))//" is invalid."
                              CALL FLAG_ERROR(LOCAL_ERROR,ERR,ERROR,*999)
                          END SELECT
                          CALL EQUATIONS_MATRICES_CREATE_FINISH(EQUATIONS_MATRICES,ERR,ERROR,*999)
                        CASE(EQUATIONS_SET_BEM_SOLUTION_METHOD)
                          CALL FLAG_ERROR("Not implemented.",ERR,ERROR,*999)
                        CASE(EQUATIONS_SET_FD_SOLUTION_METHOD)
                          CALL FLAG_ERROR("Not implemented.",ERR,ERROR,*999)
                        CASE(EQUATIONS_SET_FV_SOLUTION_METHOD)
                          CALL FLAG_ERROR("Not implemented.",ERR,ERROR,*999)
                        CASE(EQUATIONS_SET_GFEM_SOLUTION_METHOD)
                          CALL FLAG_ERROR("Not implemented.",ERR,ERROR,*999)
                        CASE(EQUATIONS_SET_GFV_SOLUTION_METHOD)
                          CALL FLAG_ERROR("Not implemented.",ERR,ERROR,*999)
                        CASE DEFAULT
                          LOCAL_ERROR="The solution method of "//TRIM(NUMBER_TO_VSTRING(EQUATIONS_SET%SOLUTION_METHOD, &
                            & "*",ERR,ERROR))//" is invalid."
                          CALL FLAG_ERROR(LOCAL_ERROR,ERR,ERROR,*999)
                      END SELECT
                    CASE DEFAULT
                      LOCAL_ERROR="The action type of "//TRIM(NUMBER_TO_VSTRING(EQUATIONS_SET_SETUP%ACTION_TYPE,"*",ERR,ERROR))// &
                        & " for a setup type of "//TRIM(NUMBER_TO_VSTRING(EQUATIONS_SET_SETUP%SETUP_TYPE,"*",ERR,ERROR))// &
                        & " is invalid for a steady Laplace equation."
                      CALL FLAG_ERROR(LOCAL_ERROR,ERR,ERROR,*999)
                  END SELECT
                CASE DEFAULT
                  LOCAL_ERROR="The equation set subtype of "//TRIM(NUMBER_TO_VSTRING(EQUATIONS_SET%SUBTYPE,"*",ERR,ERROR))// &
                    & " for a setup sub type of "//TRIM(NUMBER_TO_VSTRING(EQUATIONS_SET%SUBTYPE,"*",ERR,ERROR))// &
                    & " is invalid for a Navier-Stokes equation."
                  CALL FLAG_ERROR(LOCAL_ERROR,ERR,ERROR,*999)
              END SELECT

!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
!!! BOUNDARY CONDITIONS TYPE !!!
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

            CASE(EQUATIONS_SET_SETUP_BOUNDARY_CONDITIONS_TYPE)
              SELECT CASE(EQUATIONS_SET%SUBTYPE)
                CASE(EQUATIONS_SET_STATIC_NAVIER_STOKES_SUBTYPE,EQUATIONS_SET_LAPLACE_NAVIER_STOKES_SUBTYPE, &
                  & EQUATIONS_SET_TRANSIENT_NAVIER_STOKES_SUBTYPE,EQUATIONS_SET_ALE_NAVIER_STOKES_SUBTYPE)
                  SELECT CASE(EQUATIONS_SET_SETUP%ACTION_TYPE)
                    CASE(EQUATIONS_SET_SETUP_START_ACTION)
                      CALL EQUATIONS_SET_EQUATIONS_GET(EQUATIONS_SET,EQUATIONS,ERR,ERROR,*999)
                      IF(ASSOCIATED(EQUATIONS)) THEN
                        IF(EQUATIONS%EQUATIONS_FINISHED) THEN
                          CALL BOUNDARY_CONDITIONS_CREATE_START(EQUATIONS_SET,BOUNDARY_CONDITIONS,ERR,ERROR,*999)
                        ELSE
                          CALL FLAG_ERROR("Equations set equations has not been finished.",ERR,ERROR,*999)               
                        ENDIF
                      ELSE
                        CALL FLAG_ERROR("Equations set equations is not associated.",ERR,ERROR,*999)
                      ENDIF 
                    CASE(EQUATIONS_SET_SETUP_FINISH_ACTION)
                      CALL EQUATIONS_SET_BOUNDARY_CONDITIONS_GET(EQUATIONS_SET,BOUNDARY_CONDITIONS,ERR,ERROR,*999)
                      CALL BOUNDARY_CONDITIONS_CREATE_FINISH(BOUNDARY_CONDITIONS,ERR,ERROR,*999)
                    CASE DEFAULT
                      LOCAL_ERROR="The action type of "//TRIM(NUMBER_TO_VSTRING(EQUATIONS_SET_SETUP%ACTION_TYPE,"*", & 
                        & ERR,ERROR))//" for a setup type of "//TRIM(NUMBER_TO_VSTRING(EQUATIONS_SET_SETUP%SETUP_TYPE,"*", & 
                        & ERR,ERROR))//" is invalid for a Navier-Stokes fluid."
                      CALL FLAG_ERROR(LOCAL_ERROR,ERR,ERROR,*999)
                  END SELECT
                CASE DEFAULT
                  LOCAL_ERROR="The equation set subtype of "//TRIM(NUMBER_TO_VSTRING(EQUATIONS_SET%SUBTYPE,"*",ERR,ERROR))// &
                    & " for a setup sub type of "//TRIM(NUMBER_TO_VSTRING(EQUATIONS_SET%SUBTYPE,"*",ERR,ERROR))// &
                    & " is invalid for a Navier-Stokes equation."
                  CALL FLAG_ERROR(LOCAL_ERROR,ERR,ERROR,*999)
              END SELECT

!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
!!! CASE DEFAULT !!!
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!


            CASE DEFAULT
              LOCAL_ERROR="The setup type of "//TRIM(NUMBER_TO_VSTRING(EQUATIONS_SET_SETUP%SETUP_TYPE,"*",ERR,ERROR))// &
                & " is invalid for a Navier-Stokes fluid."
              CALL FLAG_ERROR(LOCAL_ERROR,ERR,ERROR,*999)
          END SELECT

!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
!!! THE END !!!
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

        CASE DEFAULT
          LOCAL_ERROR="The equations set subtype of "//TRIM(NUMBER_TO_VSTRING(EQUATIONS_SET%SUBTYPE,"*",ERR,ERROR))// &
            & " does not equal a Navier-Stokes fluid subtype."
          CALL FLAG_ERROR(LOCAL_ERROR,ERR,ERROR,*999)
      END SELECT
    ELSE
      CALL FLAG_ERROR("Equations set is not associated.",ERR,ERROR,*999)
    ENDIF

    CALL EXITS("NAVIER_STOKES_EQUATIONS_SET_SETUP")
    RETURN
999 CALL ERRORS("NAVIER_STOKES_EQUATIONS_SET_SETUP",ERR,ERROR)
    CALL EXITS("NAVIER_STOKES_EQUATIONS_SET_SETUP")
    RETURN 1
  END SUBROUTINE NAVIER_STOKES_EQUATIONS_SET_SETUP

! 
!================================================================================================================================
!

  !>Sets/changes the problem subtype for a Navier-Stokes fluid type .
  SUBROUTINE NAVIER_STOKES_PROBLEM_SUBTYPE_SET(PROBLEM,PROBLEM_SUBTYPE,ERR,ERROR,*)

    !Argument variables
    TYPE(PROBLEM_TYPE), POINTER :: PROBLEM !<A pointer to the problem to set the problem subtype for
    INTEGER(INTG), INTENT(IN) :: PROBLEM_SUBTYPE !<The problem subtype to set
    INTEGER(INTG), INTENT(OUT) :: ERR !<The error code
    TYPE(VARYING_STRING), INTENT(OUT) :: ERROR !<The error string
    !Local Variables
    TYPE(VARYING_STRING) :: LOCAL_ERROR

    CALL ENTERS("NAVIER_STOKES_PROBLEM_SUBTYPE_SET",ERR,ERROR,*999)

    IF(ASSOCIATED(PROBLEM)) THEN
      SELECT CASE(PROBLEM_SUBTYPE)
      CASE(PROBLEM_STATIC_NAVIER_STOKES_SUBTYPE)
        PROBLEM%CLASS=PROBLEM_FLUID_MECHANICS_CLASS
        PROBLEM%TYPE=PROBLEM_NAVIER_STOKES_EQUATION_TYPE
        PROBLEM%SUBTYPE=PROBLEM_STATIC_NAVIER_STOKES_SUBTYPE
      CASE(PROBLEM_LAPLACE_NAVIER_STOKES_SUBTYPE)
        PROBLEM%CLASS=PROBLEM_FLUID_MECHANICS_CLASS
        PROBLEM%TYPE=PROBLEM_NAVIER_STOKES_EQUATION_TYPE
        PROBLEM%SUBTYPE=PROBLEM_LAPLACE_NAVIER_STOKES_SUBTYPE
      CASE(PROBLEM_TRANSIENT_NAVIER_STOKES_SUBTYPE)
        PROBLEM%CLASS=PROBLEM_FLUID_MECHANICS_CLASS
        PROBLEM%TYPE=PROBLEM_NAVIER_STOKES_EQUATION_TYPE
        PROBLEM%SUBTYPE=PROBLEM_TRANSIENT_NAVIER_STOKES_SUBTYPE
      CASE(PROBLEM_ALE_NAVIER_STOKES_SUBTYPE)
        PROBLEM%CLASS=PROBLEM_FLUID_MECHANICS_CLASS
        PROBLEM%TYPE=PROBLEM_NAVIER_STOKES_EQUATION_TYPE
        PROBLEM%SUBTYPE=PROBLEM_ALE_NAVIER_STOKES_SUBTYPE
      CASE(PROBLEM_OPTIMISED_NAVIER_STOKES_SUBTYPE)
        CALL FLAG_ERROR("Not implemented yet.",ERR,ERROR,*999)
      CASE DEFAULT
        LOCAL_ERROR="Problem subtype "//TRIM(NUMBER_TO_VSTRING(PROBLEM_SUBTYPE,"*",ERR,ERROR))// &
          & " is not valid for a Navier-Stokes fluid type of a fluid mechanics problem class."
        CALL FLAG_ERROR(LOCAL_ERROR,ERR,ERROR,*999)
      END SELECT
    ELSE
      CALL FLAG_ERROR("Problem is not associated.",ERR,ERROR,*999)
    ENDIF

    CALL EXITS("NAVIER_STOKES_PROBLEM_SUBTYPE_SET")
    RETURN
999 CALL ERRORS("NAVIER_STOKES_PROBLEM_SUBTYPE_SET",ERR,ERROR)
    CALL EXITS("NAVIER_STOKES_PROBLEM_SUBTYPE_SET")
    RETURN 1
  END SUBROUTINE NAVIER_STOKES_PROBLEM_SUBTYPE_SET

! 
!================================================================================================================================
!
  
  !>Sets up the Navier-Stokes problem.
  SUBROUTINE NAVIER_STOKES_PROBLEM_SETUP(PROBLEM,PROBLEM_SETUP,ERR,ERROR,*)

    !Argument variables
    TYPE(PROBLEM_TYPE), POINTER :: PROBLEM !<A pointer to the problem set to setup a Navier-Stokes fluid on.
    TYPE(PROBLEM_SETUP_TYPE), INTENT(INOUT) :: PROBLEM_SETUP !<The problem setup information
    INTEGER(INTG), INTENT(OUT) :: ERR !<The error code
    TYPE(VARYING_STRING), INTENT(OUT) :: ERROR !<The error string
    !Local Variables
    TYPE(VARYING_STRING) :: LOCAL_ERROR
    TYPE(CONTROL_LOOP_TYPE), POINTER :: CONTROL_LOOP,CONTROL_LOOP_ROOT
    TYPE(SOLVER_TYPE), POINTER :: SOLVER, MESH_SOLVER
    TYPE(SOLVER_EQUATIONS_TYPE), POINTER :: SOLVER_EQUATIONS,MESH_SOLVER_EQUATIONS
    TYPE(SOLVERS_TYPE), POINTER :: SOLVERS


    CALL ENTERS("NAVIER_STOKES_PROBLEM_SETUP",ERR,ERROR,*999)

    NULLIFY(CONTROL_LOOP)
    NULLIFY(SOLVER)
    NULLIFY(MESH_SOLVER)
    NULLIFY(SOLVER_EQUATIONS)
    NULLIFY(MESH_SOLVER_EQUATIONS)
    NULLIFY(SOLVERS)
    IF(ASSOCIATED(PROBLEM)) THEN
      SELECT CASE(PROBLEM%SUBTYPE)

!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
!!! PROBLEM_STATIC_NAVIER_STOKES_SUBTYPE,PROBLEM_LAPLACE_NAVIER_STOKES_SUBTYPE !!!
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

        CASE(PROBLEM_STATIC_NAVIER_STOKES_SUBTYPE,PROBLEM_LAPLACE_NAVIER_STOKES_SUBTYPE)
          SELECT CASE(PROBLEM_SETUP%SETUP_TYPE)
            CASE(PROBLEM_SETUP_INITIAL_TYPE)
              SELECT CASE(PROBLEM_SETUP%ACTION_TYPE)
                CASE(PROBLEM_SETUP_START_ACTION)
                  !Do nothing????
                CASE(PROBLEM_SETUP_FINISH_ACTION)
                  !Do nothing???
                CASE DEFAULT
                  LOCAL_ERROR="The action type of "//TRIM(NUMBER_TO_VSTRING(PROBLEM_SETUP%ACTION_TYPE,"*",ERR,ERROR))// &
                    & " for a setup type of "//TRIM(NUMBER_TO_VSTRING(PROBLEM_SETUP%SETUP_TYPE,"*",ERR,ERROR))// &
                    & " is invalid for a Navier-Stokes fluid."
                  CALL FLAG_ERROR(LOCAL_ERROR,ERR,ERROR,*999)
              END SELECT
            CASE(PROBLEM_SETUP_CONTROL_TYPE)
              SELECT CASE(PROBLEM_SETUP%ACTION_TYPE)
                CASE(PROBLEM_SETUP_START_ACTION)
                  !Set up a simple control loop
                  CALL CONTROL_LOOP_CREATE_START(PROBLEM,CONTROL_LOOP,ERR,ERROR,*999)
                CASE(PROBLEM_SETUP_FINISH_ACTION)
                  !Finish the control loops
                  CONTROL_LOOP_ROOT=>PROBLEM%CONTROL_LOOP
                  CALL CONTROL_LOOP_GET(CONTROL_LOOP_ROOT,CONTROL_LOOP_NODE,CONTROL_LOOP,ERR,ERROR,*999)
                  CALL CONTROL_LOOP_CREATE_FINISH(CONTROL_LOOP,ERR,ERROR,*999)
                CASE DEFAULT
                  LOCAL_ERROR="The action type of "//TRIM(NUMBER_TO_VSTRING(PROBLEM_SETUP%ACTION_TYPE,"*",ERR,ERROR))// &
                    & " for a setup type of "//TRIM(NUMBER_TO_VSTRING(PROBLEM_SETUP%SETUP_TYPE,"*",ERR,ERROR))// &
                    & " is invalid for a Navier-Stokes fluid."
                  CALL FLAG_ERROR(LOCAL_ERROR,ERR,ERROR,*999)
              END SELECT
            CASE(PROBLEM_SETUP_SOLVERS_TYPE)
              !Get the control loop
              CONTROL_LOOP_ROOT=>PROBLEM%CONTROL_LOOP
              CALL CONTROL_LOOP_GET(CONTROL_LOOP_ROOT,CONTROL_LOOP_NODE,CONTROL_LOOP,ERR,ERROR,*999)
              SELECT CASE(PROBLEM_SETUP%ACTION_TYPE)
                CASE(PROBLEM_SETUP_START_ACTION)
                  !Start the solvers creation
                  CALL SOLVERS_CREATE_START(CONTROL_LOOP,SOLVERS,ERR,ERROR,*999)
                  CALL SOLVERS_NUMBER_SET(SOLVERS,1,ERR,ERROR,*999)
                  !Set the solver to be a nonlinear solver
                  CALL SOLVERS_SOLVER_GET(SOLVERS,1,SOLVER,ERR,ERROR,*999)
                  CALL SOLVER_TYPE_SET(SOLVER,SOLVER_NONLINEAR_TYPE,ERR,ERROR,*999)
                  !Set solver defaults
                  CALL SOLVER_LIBRARY_TYPE_SET(SOLVER,SOLVER_PETSC_LIBRARY,ERR,ERROR,*999)
                CASE(PROBLEM_SETUP_FINISH_ACTION)
                  !Get the solvers
                  CALL CONTROL_LOOP_SOLVERS_GET(CONTROL_LOOP,SOLVERS,ERR,ERROR,*999)
                  !Finish the solvers creation
                  CALL SOLVERS_CREATE_FINISH(SOLVERS,ERR,ERROR,*999)
                CASE DEFAULT
                  LOCAL_ERROR="The action type of "//TRIM(NUMBER_TO_VSTRING(PROBLEM_SETUP%ACTION_TYPE,"*",ERR,ERROR))// &
                    & " for a setup type of "//TRIM(NUMBER_TO_VSTRING(PROBLEM_SETUP%SETUP_TYPE,"*",ERR,ERROR))// &
                    & " is invalid for a Navier-Stokes fluid."
                  CALL FLAG_ERROR(LOCAL_ERROR,ERR,ERROR,*999)
              END SELECT
            CASE(PROBLEM_SETUP_SOLVER_EQUATIONS_TYPE)
              SELECT CASE(PROBLEM_SETUP%ACTION_TYPE)
                CASE(PROBLEM_SETUP_START_ACTION)
                  !Get the control loop
                  CONTROL_LOOP_ROOT=>PROBLEM%CONTROL_LOOP
                  CALL CONTROL_LOOP_GET(CONTROL_LOOP_ROOT,CONTROL_LOOP_NODE,CONTROL_LOOP,ERR,ERROR,*999)
                  !Get the solver
                  CALL CONTROL_LOOP_SOLVERS_GET(CONTROL_LOOP,SOLVERS,ERR,ERROR,*999)
                  CALL SOLVERS_SOLVER_GET(SOLVERS,1,SOLVER,ERR,ERROR,*999)
                  !Create the solver equations
                  CALL SOLVER_EQUATIONS_CREATE_START(SOLVER,SOLVER_EQUATIONS,ERR,ERROR,*999)
                  CALL SOLVER_EQUATIONS_LINEARITY_TYPE_SET(SOLVER_EQUATIONS,SOLVER_EQUATIONS_NONLINEAR,ERR,ERROR,*999)
                  CALL SOLVER_EQUATIONS_TIME_DEPENDENCE_TYPE_SET(SOLVER_EQUATIONS,SOLVER_EQUATIONS_STATIC,ERR,ERROR,*999)
                  CALL SOLVER_EQUATIONS_SPARSITY_TYPE_SET(SOLVER_EQUATIONS,SOLVER_SPARSE_MATRICES,ERR,ERROR,*999)
                CASE(PROBLEM_SETUP_FINISH_ACTION)
                  !Get the control loop
                  CONTROL_LOOP_ROOT=>PROBLEM%CONTROL_LOOP
                  CALL CONTROL_LOOP_GET(CONTROL_LOOP_ROOT,CONTROL_LOOP_NODE,CONTROL_LOOP,ERR,ERROR,*999)
                  !Get the solver equations
                  CALL CONTROL_LOOP_SOLVERS_GET(CONTROL_LOOP,SOLVERS,ERR,ERROR,*999)
                  CALL SOLVERS_SOLVER_GET(SOLVERS,1,SOLVER,ERR,ERROR,*999)
                  CALL SOLVER_SOLVER_EQUATIONS_GET(SOLVER,SOLVER_EQUATIONS,ERR,ERROR,*999)
                  !Finish the solver equations creation
                  CALL SOLVER_EQUATIONS_CREATE_FINISH(SOLVER_EQUATIONS,ERR,ERROR,*999)
                CASE DEFAULT
                  LOCAL_ERROR="The action type of "//TRIM(NUMBER_TO_VSTRING(PROBLEM_SETUP%ACTION_TYPE,"*",ERR,ERROR))// &
                    & " for a setup type of "//TRIM(NUMBER_TO_VSTRING(PROBLEM_SETUP%SETUP_TYPE,"*",ERR,ERROR))// &
                    & " is invalid for a Navier-Stokes fluid."
                  CALL FLAG_ERROR(LOCAL_ERROR,ERR,ERROR,*999)
              END SELECT
            CASE DEFAULT
              LOCAL_ERROR="The setup type of "//TRIM(NUMBER_TO_VSTRING(PROBLEM_SETUP%SETUP_TYPE,"*",ERR,ERROR))// &
                & " is invalid for a Navier-Stokes fluid."
              CALL FLAG_ERROR(LOCAL_ERROR,ERR,ERROR,*999)
          END SELECT

!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
!!! PROBLEM_TRANSIENT_NAVIER_STOKES_SUBTYPE !!!
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

        CASE(PROBLEM_TRANSIENT_NAVIER_STOKES_SUBTYPE)
          SELECT CASE(PROBLEM_SETUP%SETUP_TYPE)
            CASE(PROBLEM_SETUP_INITIAL_TYPE)
              SELECT CASE(PROBLEM_SETUP%ACTION_TYPE)
                CASE(PROBLEM_SETUP_START_ACTION)
                  !Do nothing????
                CASE(PROBLEM_SETUP_FINISH_ACTION)
                  !Do nothing???
                CASE DEFAULT
                  LOCAL_ERROR="The action type of "//TRIM(NUMBER_TO_VSTRING(PROBLEM_SETUP%ACTION_TYPE,"*",ERR,ERROR))// &
                    & " for a setup type of "//TRIM(NUMBER_TO_VSTRING(PROBLEM_SETUP%SETUP_TYPE,"*",ERR,ERROR))// &
                    & " is invalid for a transient Navier-Stokes fluid."
                  CALL FLAG_ERROR(LOCAL_ERROR,ERR,ERROR,*999)
              END SELECT
            CASE(PROBLEM_SETUP_CONTROL_TYPE)
              SELECT CASE(PROBLEM_SETUP%ACTION_TYPE)
                CASE(PROBLEM_SETUP_START_ACTION)
                  !Set up a time control loop
                  CALL CONTROL_LOOP_CREATE_START(PROBLEM,CONTROL_LOOP,ERR,ERROR,*999)
                  CALL CONTROL_LOOP_TYPE_SET(CONTROL_LOOP,PROBLEM_CONTROL_TIME_LOOP_TYPE,ERR,ERROR,*999)
                CASE(PROBLEM_SETUP_FINISH_ACTION)
                  !Finish the control loops
                  CONTROL_LOOP_ROOT=>PROBLEM%CONTROL_LOOP
                  CALL CONTROL_LOOP_GET(CONTROL_LOOP_ROOT,CONTROL_LOOP_NODE,CONTROL_LOOP,ERR,ERROR,*999)
                  CALL CONTROL_LOOP_CREATE_FINISH(CONTROL_LOOP,ERR,ERROR,*999)
                CASE DEFAULT
                  LOCAL_ERROR="The action type of "//TRIM(NUMBER_TO_VSTRING(PROBLEM_SETUP%ACTION_TYPE,"*",ERR,ERROR))// &
                    & " for a setup type of "//TRIM(NUMBER_TO_VSTRING(PROBLEM_SETUP%SETUP_TYPE,"*",ERR,ERROR))// &
                    & " is invalid for a transient Navier-Stokes fluid."
                  CALL FLAG_ERROR(LOCAL_ERROR,ERR,ERROR,*999)
              END SELECT
            CASE(PROBLEM_SETUP_SOLVERS_TYPE)
              !Get the control loop
              CONTROL_LOOP_ROOT=>PROBLEM%CONTROL_LOOP
              CALL CONTROL_LOOP_GET(CONTROL_LOOP_ROOT,CONTROL_LOOP_NODE,CONTROL_LOOP,ERR,ERROR,*999)
              SELECT CASE(PROBLEM_SETUP%ACTION_TYPE)
                CASE(PROBLEM_SETUP_START_ACTION)
                  !Start the solvers creation
                  CALL SOLVERS_CREATE_START(CONTROL_LOOP,SOLVERS,ERR,ERROR,*999)
                  CALL SOLVERS_NUMBER_SET(SOLVERS,1,ERR,ERROR,*999)
                  !Set the solver to be a first order dynamic solver 
                  CALL SOLVERS_SOLVER_GET(SOLVERS,1,SOLVER,ERR,ERROR,*999)
                  CALL SOLVER_TYPE_SET(SOLVER,SOLVER_DYNAMIC_TYPE,ERR,ERROR,*999)
                  CALL SOLVER_DYNAMIC_LINEARITY_TYPE_SET(SOLVER,SOLVER_DYNAMIC_NONLINEAR,ERR,ERROR,*999)
                  CALL SOLVER_DYNAMIC_ORDER_SET(SOLVER,SOLVER_DYNAMIC_FIRST_ORDER,ERR,ERROR,*999)
                  !Set solver defaults
                  CALL SOLVER_DYNAMIC_DEGREE_SET(SOLVER,SOLVER_DYNAMIC_FIRST_DEGREE,ERR,ERROR,*999)
                  CALL SOLVER_DYNAMIC_SCHEME_SET(SOLVER,SOLVER_DYNAMIC_CRANK_NICHOLSON_SCHEME,ERR,ERROR,*999)
                  CALL SOLVER_LIBRARY_TYPE_SET(SOLVER,SOLVER_CMISS_LIBRARY,ERR,ERROR,*999)
                CASE(PROBLEM_SETUP_FINISH_ACTION)
                  !Get the solvers
                  CALL CONTROL_LOOP_SOLVERS_GET(CONTROL_LOOP,SOLVERS,ERR,ERROR,*999)
                  !Finish the solvers creation
                  CALL SOLVERS_CREATE_FINISH(SOLVERS,ERR,ERROR,*999)
                CASE DEFAULT
                  LOCAL_ERROR="The action type of "//TRIM(NUMBER_TO_VSTRING(PROBLEM_SETUP%ACTION_TYPE,"*",ERR,ERROR))// &
                    & " for a setup type of "//TRIM(NUMBER_TO_VSTRING(PROBLEM_SETUP%SETUP_TYPE,"*",ERR,ERROR))// &
                    & " is invalid for a transient Navier-Stokes fluid."
                  CALL FLAG_ERROR(LOCAL_ERROR,ERR,ERROR,*999)
              END SELECT
            CASE(PROBLEM_SETUP_SOLVER_EQUATIONS_TYPE)
              SELECT CASE(PROBLEM_SETUP%ACTION_TYPE)
                CASE(PROBLEM_SETUP_START_ACTION)
                  !Get the control loop
                  CONTROL_LOOP_ROOT=>PROBLEM%CONTROL_LOOP
                  CALL CONTROL_LOOP_GET(CONTROL_LOOP_ROOT,CONTROL_LOOP_NODE,CONTROL_LOOP,ERR,ERROR,*999)
                  !Get the solver
                  CALL CONTROL_LOOP_SOLVERS_GET(CONTROL_LOOP,SOLVERS,ERR,ERROR,*999)
                  CALL SOLVERS_SOLVER_GET(SOLVERS,1,SOLVER,ERR,ERROR,*999)
                  !Create the solver equations
                  CALL SOLVER_EQUATIONS_CREATE_START(SOLVER,SOLVER_EQUATIONS,ERR,ERROR,*999)
                  CALL SOLVER_EQUATIONS_LINEARITY_TYPE_SET(SOLVER_EQUATIONS,SOLVER_EQUATIONS_NONLINEAR,ERR,ERROR,*999)
                  CALL SOLVER_EQUATIONS_TIME_DEPENDENCE_TYPE_SET(SOLVER_EQUATIONS,SOLVER_EQUATIONS_FIRST_ORDER_DYNAMIC,&
                  & ERR,ERROR,*999)
                  CALL SOLVER_EQUATIONS_SPARSITY_TYPE_SET(SOLVER_EQUATIONS,SOLVER_SPARSE_MATRICES,ERR,ERROR,*999)
                CASE(PROBLEM_SETUP_FINISH_ACTION)
                  !Get the control loop
                  CONTROL_LOOP_ROOT=>PROBLEM%CONTROL_LOOP
                  CALL CONTROL_LOOP_GET(CONTROL_LOOP_ROOT,CONTROL_LOOP_NODE,CONTROL_LOOP,ERR,ERROR,*999)
                  !Get the solver equations
                  CALL CONTROL_LOOP_SOLVERS_GET(CONTROL_LOOP,SOLVERS,ERR,ERROR,*999)
                  CALL SOLVERS_SOLVER_GET(SOLVERS,1,SOLVER,ERR,ERROR,*999)
                  CALL SOLVER_SOLVER_EQUATIONS_GET(SOLVER,SOLVER_EQUATIONS,ERR,ERROR,*999)
                  !Finish the solver equations creation
                  CALL SOLVER_EQUATIONS_CREATE_FINISH(SOLVER_EQUATIONS,ERR,ERROR,*999)
                CASE DEFAULT
                  LOCAL_ERROR="The action type of "//TRIM(NUMBER_TO_VSTRING(PROBLEM_SETUP%ACTION_TYPE,"*",ERR,ERROR))// &
                    & " for a setup type of "//TRIM(NUMBER_TO_VSTRING(PROBLEM_SETUP%SETUP_TYPE,"*",ERR,ERROR))// &
                    & " is invalid for a Navier-Stokes fluid."
                  CALL FLAG_ERROR(LOCAL_ERROR,ERR,ERROR,*999)
              END SELECT
            CASE DEFAULT
              LOCAL_ERROR="The setup type of "//TRIM(NUMBER_TO_VSTRING(PROBLEM_SETUP%SETUP_TYPE,"*",ERR,ERROR))// &
                & " is invalid for a transient Navier-Stokes fluid."
              CALL FLAG_ERROR(LOCAL_ERROR,ERR,ERROR,*999)
          END SELECT

      !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
      !!! PROBLEM_ALE_STOKES_SUBTYPE !!!
      !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

        CASE(PROBLEM_ALE_NAVIER_STOKES_SUBTYPE)
          SELECT CASE(PROBLEM_SETUP%SETUP_TYPE)
            CASE(PROBLEM_SETUP_INITIAL_TYPE)
              SELECT CASE(PROBLEM_SETUP%ACTION_TYPE)
                CASE(PROBLEM_SETUP_START_ACTION)
                  !Do nothing????
                CASE(PROBLEM_SETUP_FINISH_ACTION)
                  !Do nothing????
                CASE DEFAULT
                  LOCAL_ERROR="The action type of "//TRIM(NUMBER_TO_VSTRING(PROBLEM_SETUP%ACTION_TYPE,"*",ERR,ERROR))// &
                    & " for a setup type of "//TRIM(NUMBER_TO_VSTRING(PROBLEM_SETUP%SETUP_TYPE,"*",ERR,ERROR))// &
                    & " is invalid for a ALE Navier-Stokes fluid."
                  CALL FLAG_ERROR(LOCAL_ERROR,ERR,ERROR,*999)
              END SELECT
            CASE(PROBLEM_SETUP_CONTROL_TYPE)
              SELECT CASE(PROBLEM_SETUP%ACTION_TYPE)
                CASE(PROBLEM_SETUP_START_ACTION)
                  !Set up a time control loop
                  CALL CONTROL_LOOP_CREATE_START(PROBLEM,CONTROL_LOOP,ERR,ERROR,*999)
                  CALL CONTROL_LOOP_TYPE_SET(CONTROL_LOOP,PROBLEM_CONTROL_TIME_LOOP_TYPE,ERR,ERROR,*999)
                CASE(PROBLEM_SETUP_FINISH_ACTION)
                  !Finish the control loops
                  CONTROL_LOOP_ROOT=>PROBLEM%CONTROL_LOOP
                  CALL CONTROL_LOOP_GET(CONTROL_LOOP_ROOT,CONTROL_LOOP_NODE,CONTROL_LOOP,ERR,ERROR,*999)
                  CALL CONTROL_LOOP_CREATE_FINISH(CONTROL_LOOP,ERR,ERROR,*999)            
                CASE DEFAULT
                  LOCAL_ERROR="The action type of "//TRIM(NUMBER_TO_VSTRING(PROBLEM_SETUP%ACTION_TYPE,"*",ERR,ERROR))// &
                    & " for a setup type of "//TRIM(NUMBER_TO_VSTRING(PROBLEM_SETUP%SETUP_TYPE,"*",ERR,ERROR))// &
                    & " is invalid for a ALE Navier-Stokes fluid."
                  CALL FLAG_ERROR(LOCAL_ERROR,ERR,ERROR,*999)
              END SELECT
            CASE(PROBLEM_SETUP_SOLVERS_TYPE)
              !Get the control loop
              CONTROL_LOOP_ROOT=>PROBLEM%CONTROL_LOOP
              CALL CONTROL_LOOP_GET(CONTROL_LOOP_ROOT,CONTROL_LOOP_NODE,CONTROL_LOOP,ERR,ERROR,*999)
              SELECT CASE(PROBLEM_SETUP%ACTION_TYPE)
                CASE(PROBLEM_SETUP_START_ACTION)
                  !Start the solvers creation
                  CALL SOLVERS_CREATE_START(CONTROL_LOOP,SOLVERS,ERR,ERROR,*999)
                  CALL SOLVERS_NUMBER_SET(SOLVERS,2,ERR,ERROR,*999)
                  !Set the first solver to be a linear solver for the Laplace mesh movement problem
                  CALL SOLVERS_SOLVER_GET(SOLVERS,1,MESH_SOLVER,ERR,ERROR,*999)
                  CALL SOLVER_TYPE_SET(MESH_SOLVER,SOLVER_LINEAR_TYPE,ERR,ERROR,*999)
                  !Set solver defaults
                  CALL SOLVER_LIBRARY_TYPE_SET(MESH_SOLVER,SOLVER_PETSC_LIBRARY,ERR,ERROR,*999)
                  !Set the solver to be a first order dynamic solver 
                  CALL SOLVERS_SOLVER_GET(SOLVERS,2,SOLVER,ERR,ERROR,*999)
                  CALL SOLVER_TYPE_SET(SOLVER,SOLVER_DYNAMIC_TYPE,ERR,ERROR,*999)
                  CALL SOLVER_DYNAMIC_LINEARITY_TYPE_SET(SOLVER,SOLVER_DYNAMIC_NONLINEAR,ERR,ERROR,*999)
                  CALL SOLVER_DYNAMIC_ORDER_SET(SOLVER,SOLVER_DYNAMIC_FIRST_ORDER,ERR,ERROR,*999)
                  !Set solver defaults
                  CALL SOLVER_DYNAMIC_DEGREE_SET(SOLVER,SOLVER_DYNAMIC_FIRST_DEGREE,ERR,ERROR,*999)
                  CALL SOLVER_DYNAMIC_SCHEME_SET(SOLVER,SOLVER_DYNAMIC_CRANK_NICHOLSON_SCHEME,ERR,ERROR,*999)
                  CALL SOLVER_LIBRARY_TYPE_SET(SOLVER,SOLVER_CMISS_LIBRARY,ERR,ERROR,*999)
                CASE(PROBLEM_SETUP_FINISH_ACTION)
                  !Get the solvers
                  CALL CONTROL_LOOP_SOLVERS_GET(CONTROL_LOOP,SOLVERS,ERR,ERROR,*999)
                  !Finish the solvers creation
                  CALL SOLVERS_CREATE_FINISH(SOLVERS,ERR,ERROR,*999)
                CASE DEFAULT
                  LOCAL_ERROR="The action type of "//TRIM(NUMBER_TO_VSTRING(PROBLEM_SETUP%ACTION_TYPE,"*",ERR,ERROR))// &
                    & " for a setup type of "//TRIM(NUMBER_TO_VSTRING(PROBLEM_SETUP%SETUP_TYPE,"*",ERR,ERROR))// &
                    & " is invalid for a ALE Navier-Stokes fluid."
                  CALL FLAG_ERROR(LOCAL_ERROR,ERR,ERROR,*999)
              END SELECT
            CASE(PROBLEM_SETUP_SOLVER_EQUATIONS_TYPE)
              SELECT CASE(PROBLEM_SETUP%ACTION_TYPE)
                CASE(PROBLEM_SETUP_START_ACTION)
                  !Get the control loop
                  CONTROL_LOOP_ROOT=>PROBLEM%CONTROL_LOOP
                  CALL CONTROL_LOOP_GET(CONTROL_LOOP_ROOT,CONTROL_LOOP_NODE,CONTROL_LOOP,ERR,ERROR,*999)
                  !Get the solver
                  CALL CONTROL_LOOP_SOLVERS_GET(CONTROL_LOOP,SOLVERS,ERR,ERROR,*999)
                  CALL SOLVERS_SOLVER_GET(SOLVERS,1,MESH_SOLVER,ERR,ERROR,*999)
                  !Create the solver equations
                  CALL SOLVER_EQUATIONS_CREATE_START(MESH_SOLVER,MESH_SOLVER_EQUATIONS,ERR,ERROR,*999)
                  CALL SOLVER_EQUATIONS_LINEARITY_TYPE_SET(MESH_SOLVER_EQUATIONS,SOLVER_EQUATIONS_LINEAR,ERR,ERROR,*999)
                  CALL SOLVER_EQUATIONS_TIME_DEPENDENCE_TYPE_SET(MESH_SOLVER_EQUATIONS,SOLVER_EQUATIONS_STATIC,ERR,ERROR,*999)
                  CALL SOLVER_EQUATIONS_SPARSITY_TYPE_SET(MESH_SOLVER_EQUATIONS,SOLVER_SPARSE_MATRICES,ERR,ERROR,*999)
                  CALL SOLVERS_SOLVER_GET(SOLVERS,2,SOLVER,ERR,ERROR,*999)
                  !Create the solver equations
                  CALL SOLVER_EQUATIONS_CREATE_START(SOLVER,SOLVER_EQUATIONS,ERR,ERROR,*999)
                  CALL SOLVER_EQUATIONS_LINEARITY_TYPE_SET(SOLVER_EQUATIONS,SOLVER_EQUATIONS_NONLINEAR,ERR,ERROR,*999)
                  CALL SOLVER_EQUATIONS_TIME_DEPENDENCE_TYPE_SET(SOLVER_EQUATIONS,SOLVER_EQUATIONS_FIRST_ORDER_DYNAMIC,&
                  & ERR,ERROR,*999)
                  CALL SOLVER_EQUATIONS_SPARSITY_TYPE_SET(SOLVER_EQUATIONS,SOLVER_SPARSE_MATRICES,ERR,ERROR,*999)
                CASE(PROBLEM_SETUP_FINISH_ACTION)
                  !Get the control loop
                  CONTROL_LOOP_ROOT=>PROBLEM%CONTROL_LOOP
                  CALL CONTROL_LOOP_GET(CONTROL_LOOP_ROOT,CONTROL_LOOP_NODE,CONTROL_LOOP,ERR,ERROR,*999)
                  !Get the solver equations
                  CALL CONTROL_LOOP_SOLVERS_GET(CONTROL_LOOP,SOLVERS,ERR,ERROR,*999)
                  CALL SOLVERS_SOLVER_GET(SOLVERS,1,MESH_SOLVER,ERR,ERROR,*999)
                  CALL SOLVER_SOLVER_EQUATIONS_GET(MESH_SOLVER,MESH_SOLVER_EQUATIONS,ERR,ERROR,*999)
                  !Finish the solver equations creation
                  CALL SOLVER_EQUATIONS_CREATE_FINISH(MESH_SOLVER_EQUATIONS,ERR,ERROR,*999)             

                  CALL SOLVERS_SOLVER_GET(SOLVERS,2,SOLVER,ERR,ERROR,*999)
                  CALL SOLVER_SOLVER_EQUATIONS_GET(SOLVER,SOLVER_EQUATIONS,ERR,ERROR,*999)
                  !Finish the solver equations creation
                  CALL SOLVER_EQUATIONS_CREATE_FINISH(SOLVER_EQUATIONS,ERR,ERROR,*999)             


                CASE DEFAULT
                  LOCAL_ERROR="The action type of "//TRIM(NUMBER_TO_VSTRING(PROBLEM_SETUP%ACTION_TYPE,"*",ERR,ERROR))// &
                    & " for a setup type of "//TRIM(NUMBER_TO_VSTRING(PROBLEM_SETUP%SETUP_TYPE,"*",ERR,ERROR))// &
                    & " is invalid for a Navier-Stokes fluid."
                  CALL FLAG_ERROR(LOCAL_ERROR,ERR,ERROR,*999)
              END SELECT
            CASE DEFAULT
              LOCAL_ERROR="The setup type of "//TRIM(NUMBER_TO_VSTRING(PROBLEM_SETUP%SETUP_TYPE,"*",ERR,ERROR))// &
                & " is invalid for a ALE Navier-Stokes fluid."
              CALL FLAG_ERROR(LOCAL_ERROR,ERR,ERROR,*999)
          END SELECT

!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
!!! DEFAULT !!!
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

        CASE DEFAULT
          LOCAL_ERROR="Problem subtype "//TRIM(NUMBER_TO_VSTRING(PROBLEM%SUBTYPE,"*",ERR,ERROR))// &
            & " is not valid for a Navier-Stokes equation type of a fluid mechanics problem class."
          CALL FLAG_ERROR(LOCAL_ERROR,ERR,ERROR,*999)
      END SELECT
    ELSE
      CALL FLAG_ERROR("Problem is not associated.",ERR,ERROR,*999)
    ENDIF

    CALL EXITS("NAVIER_STOKES_PROBLEM_SETUP")
    RETURN
999 CALL ERRORS("NAVIER_STOKES_PROBLEM_SETUP",ERR,ERROR)
    CALL EXITS("NAVIER_STOKES_PROBLEM_SETUP")
    RETURN 1
  END SUBROUTINE NAVIER_STOKES_PROBLEM_SETUP

  !
  !================================================================================================================================
  !

  !>Evaluates the residual element stiffness matrices and RHS for a Navier-Stokes equation finite element equations set.
  SUBROUTINE NAVIER_STOKES_FINITE_ELEMENT_RESIDUAL_EVALUATE(EQUATIONS_SET,ELEMENT_NUMBER,ERR,ERROR,*)

    !Argument variables
    TYPE(EQUATIONS_SET_TYPE), POINTER :: EQUATIONS_SET !<A pointer to the equations set to perform the finite element calculations on
    INTEGER(INTG), INTENT(IN) :: ELEMENT_NUMBER !<The element number to calculate
    INTEGER(INTG), INTENT(OUT) :: ERR !<The error code
    TYPE(VARYING_STRING), INTENT(OUT) :: ERROR !<The error string
    !Local Variables
    INTEGER(INTG) ng,mh,mhs,mi,ms,nh,nhs,ni,ns,MESH_COMPONENT1,MESH_COMPONENT2, nhs_max, mhs_max, nhs_min, mhs_min
    REAL(DP) :: JGW,SUM,DXI_DX(3,3),PHIMS,PHINS,MU_PARAM,RHO_PARAM,DPHIMS_DXI(3),DPHINS_DXI(3)
    TYPE(BASIS_TYPE), POINTER :: DEPENDENT_BASIS,DEPENDENT_BASIS1,DEPENDENT_BASIS2,GEOMETRIC_BASIS,INDEPENDENT_BASIS
    TYPE(EQUATIONS_TYPE), POINTER :: EQUATIONS
    TYPE(EQUATIONS_MAPPING_TYPE), POINTER :: EQUATIONS_MAPPING

    TYPE(EQUATIONS_MAPPING_LINEAR_TYPE), POINTER :: LINEAR_MAPPING
    TYPE(EQUATIONS_MAPPING_DYNAMIC_TYPE), POINTER :: DYNAMIC_MAPPING
    TYPE(EQUATIONS_MAPPING_NONLINEAR_TYPE), POINTER :: NONLINEAR_MAPPING

    TYPE(EQUATIONS_MATRICES_TYPE), POINTER :: EQUATIONS_MATRICES
    TYPE(EQUATIONS_MATRICES_LINEAR_TYPE), POINTER :: LINEAR_MATRICES
    TYPE(EQUATIONS_MATRICES_DYNAMIC_TYPE), POINTER :: DYNAMIC_MATRICES
    TYPE(EQUATIONS_MATRICES_NONLINEAR_TYPE), POINTER :: NONLINEAR_MATRICES

    TYPE(EQUATIONS_MATRICES_RHS_TYPE), POINTER :: RHS_VECTOR
!    TYPE(EQUATIONS_MATRICES_SOURCE_TYPE), POINTER :: SOURCE_VECTOR

    TYPE(EQUATIONS_MATRIX_TYPE), POINTER :: STIFFNESS_MATRIX, DAMPING_MATRIX
    TYPE(FIELD_TYPE), POINTER :: DEPENDENT_FIELD,GEOMETRIC_FIELD,MATERIALS_FIELD,INDEPENDENT_FIELD
    TYPE(FIELD_VARIABLE_TYPE), POINTER :: FIELD_VARIABLE
    TYPE(QUADRATURE_SCHEME_TYPE), POINTER :: QUADRATURE_SCHEME,QUADRATURE_SCHEME1,QUADRATURE_SCHEME2
    TYPE(VARYING_STRING) :: LOCAL_ERROR
    INTEGER(INTG) :: x,out
!    LOGICAL :: GRADIENT_TRANSPOSE

!    REAL(DP) :: test(89,89),test2(89,89),scaling,square
    REAL(DP) :: AG_MATRIX(256,256) ! "A" Matrix ("G"radient part) - maximum size allocated
    REAL(DP) :: AL_MATRIX(256,256) ! "A" Matrix ("L"aplace part) - maximum size allocated
    REAL(DP) :: ALE_MATRIX(256,256) ! "A"rbitrary "L"agrangian "E"ulerian Matrix - maximum size allocated
    REAL(DP) :: BT_MATRIX(256,256) ! "B" "T"ranspose Matrix - maximum size allocated
    REAL(DP) :: MT_MATRIX(256,256) ! "M"ass "T"ime Matrix - maximum size allocated
    REAL(DP) :: CT_MATRIX(256,256) ! "C"onvective "T"erm Matrix - maximum size allocated
    REAL(DP) :: RH_VECTOR(256) ! "R"ight "H"and vector - maximum size allocated
    REAL(DP) :: NL_VECTOR(256) ! "N"on "L"inear vector - maximum size allocated
    
    REAL(DP) :: U_VALUE(3),W_VALUE(3)
    REAL(DP) :: U_DERIV(3,3)

    
    CALL ENTERS("NAVIER_STOKES_FINITE_ELEMENT_RESIDUAL_EVALUATE",ERR,ERROR,*999)

    out=0
    AG_MATRIX=0.0_DP
    AL_MATRIX=0.0_DP
    ALE_MATRIX=0.0_DP
    BT_MATRIX=0.0_DP
    MT_MATRIX=0.0_DP
    CT_MATRIX=0.0_DP
    RH_VECTOR=0.0_DP
    NL_VECTOR=0.0_DP

    IF(ASSOCIATED(EQUATIONS_SET)) THEN
      EQUATIONS=>EQUATIONS_SET%EQUATIONS
      IF(ASSOCIATED(EQUATIONS)) THEN
        SELECT CASE(EQUATIONS_SET%SUBTYPE)
        CASE(EQUATIONS_SET_STATIC_NAVIER_STOKES_SUBTYPE,EQUATIONS_SET_LAPLACE_NAVIER_STOKES_SUBTYPE, &
          & EQUATIONS_SET_TRANSIENT_NAVIER_STOKES_SUBTYPE,EQUATIONS_SET_ALE_NAVIER_STOKES_SUBTYPE)

!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
!!! SET POINTERS !!!
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

          DEPENDENT_FIELD=>EQUATIONS%INTERPOLATION%DEPENDENT_FIELD
          GEOMETRIC_FIELD=>EQUATIONS%INTERPOLATION%GEOMETRIC_FIELD
          MATERIALS_FIELD=>EQUATIONS%INTERPOLATION%MATERIALS_FIELD
          EQUATIONS_MATRICES=>EQUATIONS%EQUATIONS_MATRICES
          GEOMETRIC_BASIS=>GEOMETRIC_FIELD%DECOMPOSITION%DOMAIN(GEOMETRIC_FIELD%DECOMPOSITION%MESH_COMPONENT_NUMBER)%PTR% &
            & TOPOLOGY%ELEMENTS%ELEMENTS(ELEMENT_NUMBER)%BASIS
          DEPENDENT_BASIS=>DEPENDENT_FIELD%DECOMPOSITION%DOMAIN(DEPENDENT_FIELD%DECOMPOSITION%MESH_COMPONENT_NUMBER)%PTR% &
            & TOPOLOGY%ELEMENTS%ELEMENTS(ELEMENT_NUMBER)%BASIS
          QUADRATURE_SCHEME=>DEPENDENT_BASIS%QUADRATURE%QUADRATURE_SCHEME_MAP(BASIS_DEFAULT_QUADRATURE_SCHEME)%PTR
          RHS_VECTOR=>EQUATIONS_MATRICES%RHS_VECTOR
          EQUATIONS_MAPPING=>EQUATIONS%EQUATIONS_MAPPING

          SELECT CASE(EQUATIONS_SET%SUBTYPE)
            CASE(EQUATIONS_SET_STATIC_NAVIER_STOKES_SUBTYPE,EQUATIONS_SET_LAPLACE_NAVIER_STOKES_SUBTYPE)
              LINEAR_MATRICES=>EQUATIONS_MATRICES%LINEAR_MATRICES
              NONLINEAR_MATRICES=>EQUATIONS_MATRICES%NONLINEAR_MATRICES
              STIFFNESS_MATRIX=>LINEAR_MATRICES%MATRICES(1)%PTR
              LINEAR_MAPPING=>EQUATIONS_MAPPING%LINEAR_MAPPING
              NONLINEAR_MAPPING=>EQUATIONS_MAPPING%NONLINEAR_MAPPING
              !                 FIELD_VARIABLE=>LINEAR_MAPPING%EQUATIONS_MATRIX_TO_VAR_MAPS(1)%VARIABLE
              FIELD_VARIABLE=>NONLINEAR_MAPPING%RESIDUAL_VARIABLE
              !                 SOURCE_VECTOR=>EQUATIONS_MATRICES%SOURCE_VECTOR
              STIFFNESS_MATRIX%ELEMENT_MATRIX%MATRIX=0.0_DP
              NONLINEAR_MATRICES%ELEMENT_RESIDUAL%VECTOR=0.0_DP
            CASE(EQUATIONS_SET_TRANSIENT_NAVIER_STOKES_SUBTYPE)
              DYNAMIC_MATRICES=>EQUATIONS_MATRICES%DYNAMIC_MATRICES
              STIFFNESS_MATRIX=>DYNAMIC_MATRICES%MATRICES(1)%PTR
              DAMPING_MATRIX=>DYNAMIC_MATRICES%MATRICES(2)%PTR
              NONLINEAR_MATRICES=>EQUATIONS_MATRICES%NONLINEAR_MATRICES
              DYNAMIC_MAPPING=>EQUATIONS_MAPPING%DYNAMIC_MAPPING
              NONLINEAR_MAPPING=>EQUATIONS_MAPPING%NONLINEAR_MAPPING
              FIELD_VARIABLE=>NONLINEAR_MAPPING%RESIDUAL_VARIABLE
              STIFFNESS_MATRIX%ELEMENT_MATRIX%MATRIX=0.0_DP
              DAMPING_MATRIX%ELEMENT_MATRIX%MATRIX=0.0_DP
              NONLINEAR_MATRICES%ELEMENT_RESIDUAL%VECTOR=0.0_DP
            CASE(EQUATIONS_SET_ALE_NAVIER_STOKES_SUBTYPE)
              INDEPENDENT_FIELD=>EQUATIONS%INTERPOLATION%INDEPENDENT_FIELD
              INDEPENDENT_BASIS=>INDEPENDENT_FIELD%DECOMPOSITION%DOMAIN(INDEPENDENT_FIELD%DECOMPOSITION%MESH_COMPONENT_NUMBER)% & 
                & PTR%TOPOLOGY%ELEMENTS%ELEMENTS(ELEMENT_NUMBER)%BASIS

              DYNAMIC_MATRICES=>EQUATIONS_MATRICES%DYNAMIC_MATRICES
              STIFFNESS_MATRIX=>DYNAMIC_MATRICES%MATRICES(1)%PTR
              DAMPING_MATRIX=>DYNAMIC_MATRICES%MATRICES(2)%PTR
              NONLINEAR_MATRICES=>EQUATIONS_MATRICES%NONLINEAR_MATRICES
              DYNAMIC_MAPPING=>EQUATIONS_MAPPING%DYNAMIC_MAPPING
              NONLINEAR_MAPPING=>EQUATIONS_MAPPING%NONLINEAR_MAPPING
              FIELD_VARIABLE=>NONLINEAR_MAPPING%RESIDUAL_VARIABLE
              STIFFNESS_MATRIX%ELEMENT_MATRIX%MATRIX=0.0_DP
              DAMPING_MATRIX%ELEMENT_MATRIX%MATRIX=0.0_DP
              NONLINEAR_MATRICES%ELEMENT_RESIDUAL%VECTOR=0.0_DP

              CALL FIELD_INTERPOLATION_PARAMETERS_ELEMENT_GET(FIELD_MESH_VELOCITY_SET_TYPE,ELEMENT_NUMBER,EQUATIONS%INTERPOLATION% &
                & INDEPENDENT_INTERP_PARAMETERS,ERR,ERROR,*999)
            CASE DEFAULT
              LOCAL_ERROR="Equations set subtype "//TRIM(NUMBER_TO_VSTRING(EQUATIONS_SET%SUBTYPE,"*",ERR,ERROR))// &
                & " is not valid for a Navier-Stokes fluid type of a fluid mechanics equations set class."
              CALL FLAG_ERROR(LOCAL_ERROR,ERR,ERROR,*999)
          END SELECT

          CALL FIELD_INTERPOLATION_PARAMETERS_ELEMENT_GET(FIELD_VALUES_SET_TYPE,ELEMENT_NUMBER,EQUATIONS%INTERPOLATION% &
            & DEPENDENT_INTERP_PARAMETERS,ERR,ERROR,*999)
          CALL FIELD_INTERPOLATION_PARAMETERS_ELEMENT_GET(FIELD_VALUES_SET_TYPE,ELEMENT_NUMBER,EQUATIONS%INTERPOLATION% &
            & GEOMETRIC_INTERP_PARAMETERS,ERR,ERROR,*999)
          CALL FIELD_INTERPOLATION_PARAMETERS_ELEMENT_GET(FIELD_VALUES_SET_TYPE,ELEMENT_NUMBER,EQUATIONS%INTERPOLATION% &
            & MATERIALS_INTERP_PARAMETERS,ERR,ERROR,*999)

!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
!!! LOOP OVER GAUSS POINTS !!!
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

          DO ng=1,QUADRATURE_SCHEME%NUMBER_OF_GAUSS
            CALL FIELD_INTERPOLATE_GAUSS(FIRST_PART_DERIV,BASIS_DEFAULT_QUADRATURE_SCHEME,ng,EQUATIONS%INTERPOLATION% &
              & DEPENDENT_INTERP_POINT,ERR,ERROR,*999)
            CALL FIELD_INTERPOLATE_GAUSS(FIRST_PART_DERIV,BASIS_DEFAULT_QUADRATURE_SCHEME,ng,EQUATIONS%INTERPOLATION% &
              & GEOMETRIC_INTERP_POINT,ERR,ERROR,*999)
            CALL FIELD_INTERPOLATED_POINT_METRICS_CALCULATE(GEOMETRIC_BASIS%NUMBER_OF_XI,EQUATIONS%INTERPOLATION% &
              & GEOMETRIC_INTERP_POINT_METRICS,ERR,ERROR,*999)
            CALL FIELD_INTERPOLATE_GAUSS(NO_PART_DERIV,BASIS_DEFAULT_QUADRATURE_SCHEME,ng,EQUATIONS%INTERPOLATION% &
              & MATERIALS_INTERP_POINT,ERR,ERROR,*999)

            IF(EQUATIONS_SET%SUBTYPE==EQUATIONS_SET_ALE_NAVIER_STOKES_SUBTYPE) THEN
              CALL FIELD_INTERPOLATE_GAUSS(FIRST_PART_DERIV,BASIS_DEFAULT_QUADRATURE_SCHEME,ng,EQUATIONS%INTERPOLATION% &
                & INDEPENDENT_INTERP_POINT,ERR,ERROR,*999)
                W_VALUE(1)=EQUATIONS%INTERPOLATION%INDEPENDENT_INTERP_POINT%VALUES(1,NO_PART_DERIV)
                W_VALUE(2)=EQUATIONS%INTERPOLATION%INDEPENDENT_INTERP_POINT%VALUES(2,NO_PART_DERIV)
                IF(FIELD_VARIABLE%NUMBER_OF_COMPONENTS==4) THEN
                  W_VALUE(3)=EQUATIONS%INTERPOLATION%INDEPENDENT_INTERP_POINT%VALUES(3,NO_PART_DERIV)
                END IF 
            ELSE
              W_VALUE=0.0_DP
            END IF

            !Define MU_PARAM, viscosity=1
            MU_PARAM=EQUATIONS%INTERPOLATION%MATERIALS_INTERP_POINT%VALUES(1,NO_PART_DERIV)
            !Define RHO_PARAM, density=2
            RHO_PARAM=EQUATIONS%INTERPOLATION%MATERIALS_INTERP_POINT%VALUES(2,NO_PART_DERIV)

!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
!!! CALCULATE PARTIAL MATRICES !!!
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

            IF(EQUATIONS_SET%SUBTYPE==EQUATIONS_SET_STATIC_NAVIER_STOKES_SUBTYPE.OR. &
              & EQUATIONS_SET%SUBTYPE==EQUATIONS_SET_LAPLACE_NAVIER_STOKES_SUBTYPE.OR. &
              & EQUATIONS_SET%SUBTYPE==EQUATIONS_SET_TRANSIENT_NAVIER_STOKES_SUBTYPE.OR. &
              & EQUATIONS_SET%SUBTYPE==EQUATIONS_SET_ALE_NAVIER_STOKES_SUBTYPE) THEN
              !Loop over field components
              mhs=0
              DO mh=1,(FIELD_VARIABLE%NUMBER_OF_COMPONENTS-1)
                MESH_COMPONENT1=FIELD_VARIABLE%COMPONENTS(mh)%MESH_COMPONENT_NUMBER
                DEPENDENT_BASIS1=>DEPENDENT_FIELD%DECOMPOSITION%DOMAIN(MESH_COMPONENT1)%PTR% &
                  & TOPOLOGY%ELEMENTS%ELEMENTS(ELEMENT_NUMBER)%BASIS
                QUADRATURE_SCHEME1=>DEPENDENT_BASIS1%QUADRATURE%QUADRATURE_SCHEME_MAP(BASIS_DEFAULT_QUADRATURE_SCHEME)%PTR
                JGW=EQUATIONS%INTERPOLATION%GEOMETRIC_INTERP_POINT_METRICS%JACOBIAN*QUADRATURE_SCHEME1%GAUSS_WEIGHTS(ng)
                DO ms=1,DEPENDENT_BASIS1%NUMBER_OF_ELEMENT_PARAMETERS
                  mhs=mhs+1
                  nhs=0
                  IF(STIFFNESS_MATRIX%UPDATE_MATRIX.OR.DAMPING_MATRIX%UPDATE_MATRIX) THEN
                    !Loop over element columns
                    DO nh=1,(FIELD_VARIABLE%NUMBER_OF_COMPONENTS)
                      MESH_COMPONENT2=FIELD_VARIABLE%COMPONENTS(nh)%MESH_COMPONENT_NUMBER
                      DEPENDENT_BASIS2=>DEPENDENT_FIELD%DECOMPOSITION%DOMAIN(MESH_COMPONENT2)%PTR% &
                        & TOPOLOGY%ELEMENTS%ELEMENTS(ELEMENT_NUMBER)%BASIS
                      QUADRATURE_SCHEME2=>DEPENDENT_BASIS2%QUADRATURE%QUADRATURE_SCHEME_MAP&
                        &(BASIS_DEFAULT_QUADRATURE_SCHEME)%PTR
                      ! JGW=EQUATIONS%INTERPOLATION%GEOMETRIC_INTERP_POINT_METRICS%JACOBIAN*QUADRATURE_SCHEME2%&
                      ! &GAUSS_WEIGHTS(ng)                        
                      DO ns=1,DEPENDENT_BASIS2%NUMBER_OF_ELEMENT_PARAMETERS
                        nhs=nhs+1

!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
!!! PRECONDITIONS !!!
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

                        DO ni=1,DEPENDENT_BASIS2%NUMBER_OF_XI
                          DO mi=1,DEPENDENT_BASIS1%NUMBER_OF_XI
                            DXI_DX(mi,ni)=EQUATIONS%INTERPOLATION%GEOMETRIC_INTERP_POINT_METRICS%DXI_DX(mi,ni)
                          END DO
                          DPHIMS_DXI(ni)=QUADRATURE_SCHEME1%GAUSS_BASIS_FNS(ms,PARTIAL_DERIVATIVE_FIRST_DERIVATIVE_MAP(ni),ng)
                          DPHINS_DXI(ni)=QUADRATURE_SCHEME2%GAUSS_BASIS_FNS(ns,PARTIAL_DERIVATIVE_FIRST_DERIVATIVE_MAP(ni),ng)
                        END DO !ni
                        PHIMS=QUADRATURE_SCHEME1%GAUSS_BASIS_FNS(ms,NO_PART_DERIV,ng)
                        PHINS=QUADRATURE_SCHEME2%GAUSS_BASIS_FNS(ns,NO_PART_DERIV,ng)

!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
!!! A LAPLACE ONLY !!!
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

                        IF(STIFFNESS_MATRIX%UPDATE_MATRIX) THEN
                          !LAPLACE TYPE 
                          IF(nh==mh) THEN 
                            SUM=0.0_DP
                            !Calculate SUM 
                            DO x=1,DEPENDENT_BASIS1%NUMBER_OF_XI
                              DO mi=1,DEPENDENT_BASIS1%NUMBER_OF_XI
                                DO ni=1,DEPENDENT_BASIS2%NUMBER_OF_XI
                                  SUM=SUM+MU_PARAM*DPHINS_DXI(ni)*DXI_DX(ni,x)*DPHIMS_DXI(mi)*DXI_DX(mi,x)
                                ENDDO !ni
                              ENDDO !mi
                            ENDDO !x 
                            !Calculate MATRIX  
                            AL_MATRIX(mhs,nhs)=AL_MATRIX(mhs,nhs)+SUM*JGW
                          END IF
                        END IF

!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
!!! A STANDARD !!!
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

                        IF(STIFFNESS_MATRIX%UPDATE_MATRIX) THEN
                          !GRADIENT TRANSPOSE TYPE
                          IF(EQUATIONS_SET%SUBTYPE/=EQUATIONS_SET_LAPLACE_NAVIER_STOKES_SUBTYPE) THEN 
                            IF(nh<FIELD_VARIABLE%NUMBER_OF_COMPONENTS) THEN 
                              SUM=0.0_DP
                              !Calculate SUM 
                              DO mi=1,DEPENDENT_BASIS1%NUMBER_OF_XI
                                DO ni=1,DEPENDENT_BASIS2%NUMBER_OF_XI
                                  !note mh/nh derivative in DXI_DX 
                                  SUM=SUM+MU_PARAM*DPHINS_DXI(mi)*DXI_DX(mi,mh)*DPHIMS_DXI(ni)*DXI_DX(ni,nh)
                                ENDDO !ni
                              ENDDO !mi
                              !Calculate MATRIX
                              AG_MATRIX(mhs,nhs)=AG_MATRIX(mhs,nhs)+SUM*JGW
                            END IF
                          END IF
                        END IF

!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
!!! ALE CONTRIBUTION !!! 
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

                          !This part must be either here or within the nonlinear vector
                          !To be proved that there is no difference
                          IF(STIFFNESS_MATRIX%UPDATE_MATRIX) THEN
                            !GRADIENT TRANSPOSE TYPE
                            IF(EQUATIONS_SET%SUBTYPE==EQUATIONS_SET_ALE_NAVIER_STOKES_SUBTYPE) THEN 
                              IF(nh==mh) THEN 
                                SUM=0.0_DP
                                !Calculate SUM 
                                DO mi=1,DEPENDENT_BASIS1%NUMBER_OF_XI
                                  DO ni=1,DEPENDENT_BASIS1%NUMBER_OF_XI
                                    SUM=SUM-RHO_PARAM*W_VALUE(mi)*DPHINS_DXI(ni)*DXI_DX(ni,mi)*PHIMS
                                  ENDDO !ni
                                ENDDO !mi
                                !Calculate MATRIX
                                ALE_MATRIX(mhs,nhs)=ALE_MATRIX(mhs,nhs)+SUM*JGW
                              END IF
                            END IF
                          END IF

!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
!!! B TRANSPOSE !!!
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

                        IF(STIFFNESS_MATRIX%UPDATE_MATRIX) THEN
                          !LAPLACE TYPE 
                          IF(nh==FIELD_VARIABLE%NUMBER_OF_COMPONENTS) THEN 
                            SUM=0.0_DP
                            !Calculate SUM 
                            DO ni=1,DEPENDENT_BASIS1%NUMBER_OF_XI
                              SUM=SUM-PHINS*DPHIMS_DXI(ni)*DXI_DX(ni,mh)
                            ENDDO !ni
                            !Calculate MATRIX
                            BT_MATRIX(mhs,nhs)=BT_MATRIX(mhs,nhs)+SUM*JGW
                          END IF
                        END IF

!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
!!! M !!!
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

                        IF(EQUATIONS_SET%SUBTYPE==EQUATIONS_SET_TRANSIENT_NAVIER_STOKES_SUBTYPE.OR. &
                          & EQUATIONS_SET%SUBTYPE==EQUATIONS_SET_ALE_NAVIER_STOKES_SUBTYPE) THEN
                          IF(DAMPING_MATRIX%UPDATE_MATRIX) THEN
                            IF(nh==mh) THEN 
                              SUM=0.0_DP 
                              !Calculate SUM 
                              SUM=PHIMS*PHINS*RHO_PARAM
                              !Calculate MATRIX
                              MT_MATRIX(mhs,nhs)=MT_MATRIX(mhs,nhs)+SUM*JGW
                            END IF
                          END IF
                        END IF

                      ENDDO !ns
                    ENDDO !nh
!!! GO TO MATRIX ASSEMBLY !!!
                  ENDIF
                ENDDO !ms
              ENDDO !mh

!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
!!! CALCULATE RHS !!!
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

              IF(RHS_VECTOR%FIRST_ASSEMBLY) THEN
                IF(RHS_VECTOR%UPDATE_VECTOR) THEN
                  RH_VECTOR=0.0_DP                  
!!! GO TO MATRIX ASSEMBLY !!!
                ENDIF
              ENDIF

!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
!!! CALCULATE NONLINEAR VECTOR !!!
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

              IF(NONLINEAR_MATRICES%UPDATE_RESIDUAL) THEN
                U_VALUE(1)=EQUATIONS%INTERPOLATION%DEPENDENT_INTERP_POINT%VALUES(1,NO_PART_DERIV)
                U_VALUE(2)=EQUATIONS%INTERPOLATION%DEPENDENT_INTERP_POINT%VALUES(2,NO_PART_DERIV)
                U_DERIV(1,1)=EQUATIONS%INTERPOLATION%DEPENDENT_INTERP_POINT%VALUES(1,PART_DERIV_S1)
                U_DERIV(1,2)=EQUATIONS%INTERPOLATION%DEPENDENT_INTERP_POINT%VALUES(1,PART_DERIV_S2)
                U_DERIV(2,1)=EQUATIONS%INTERPOLATION%DEPENDENT_INTERP_POINT%VALUES(2,PART_DERIV_S1)
                U_DERIV(2,2)=EQUATIONS%INTERPOLATION%DEPENDENT_INTERP_POINT%VALUES(2,PART_DERIV_S2)
                IF(FIELD_VARIABLE%NUMBER_OF_COMPONENTS==4) THEN
                  U_VALUE(3)=EQUATIONS%INTERPOLATION%DEPENDENT_INTERP_POINT%VALUES(3,NO_PART_DERIV)
                  U_DERIV(3,1)=EQUATIONS%INTERPOLATION%DEPENDENT_INTERP_POINT%VALUES(3,PART_DERIV_S1)
                  U_DERIV(3,2)=EQUATIONS%INTERPOLATION%DEPENDENT_INTERP_POINT%VALUES(3,PART_DERIV_S2)
                  U_DERIV(3,3)=EQUATIONS%INTERPOLATION%DEPENDENT_INTERP_POINT%VALUES(3,PART_DERIV_S3)
                  U_DERIV(1,3)=EQUATIONS%INTERPOLATION%DEPENDENT_INTERP_POINT%VALUES(1,PART_DERIV_S3)
                  U_DERIV(2,3)=EQUATIONS%INTERPOLATION%DEPENDENT_INTERP_POINT%VALUES(2,PART_DERIV_S3) 
                ELSE
                  U_VALUE(3)=0.0_DP
                  U_DERIV(3,1)=0.0_DP
                  U_DERIV(3,2)=0.0_DP
                  U_DERIV(3,3)=0.0_DP
                  U_DERIV(1,3)=0.0_DP
                  U_DERIV(2,3)=0.0_DP
                END IF

                !Here W_VALUES must be ZERO if ALE part of linear matrix
                W_VALUE=0.0_DP

                mhs=0
                DO mh=1,(FIELD_VARIABLE%NUMBER_OF_COMPONENTS-1)
                  MESH_COMPONENT1=FIELD_VARIABLE%COMPONENTS(mh)%MESH_COMPONENT_NUMBER
                  DEPENDENT_BASIS1=>DEPENDENT_FIELD%DECOMPOSITION%DOMAIN(MESH_COMPONENT1)%PTR% &
                    & TOPOLOGY%ELEMENTS%ELEMENTS(ELEMENT_NUMBER)%BASIS
                  QUADRATURE_SCHEME1=>DEPENDENT_BASIS1%QUADRATURE%QUADRATURE_SCHEME_MAP(BASIS_DEFAULT_QUADRATURE_SCHEME)%PTR
                  JGW=EQUATIONS%INTERPOLATION%GEOMETRIC_INTERP_POINT_METRICS%JACOBIAN*QUADRATURE_SCHEME1%GAUSS_WEIGHTS(ng)
                  DO ms=1,DEPENDENT_BASIS1%NUMBER_OF_ELEMENT_PARAMETERS
                    mhs=mhs+1
                    PHIMS=QUADRATURE_SCHEME1%GAUSS_BASIS_FNS(ms,NO_PART_DERIV,ng)
                    !note mh value derivative 
                    SUM=0.0_DP 
                    SUM=RHO_PARAM*PHIMS*( & 
                      & (U_VALUE(1)-W_VALUE(1))*U_DERIV(mh,1) + &
                      & (U_VALUE(2)-W_VALUE(2))*U_DERIV(mh,2) + & 
                      & (U_VALUE(3)-W_VALUE(3))*U_DERIV(mh,3))
                    NL_VECTOR(mhs)=NL_VECTOR(mhs)+SUM*JGW
!!! GO TO MATRIX ASSEMBLY !!!
                  ENDDO !ms
                ENDDO !mh
              ENDIF
            ENDIF
          ENDDO !ng

!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
!!! ASSEMBLE STIFFNESS AND VECTORS !!!
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

          mhs_min=mhs
          mhs_max=nhs
          nhs_min=mhs
          nhs_max=nhs

!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
!!! ASSEMBLE STIFFNESS & DAMPING MATRIX !!!
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

      
          IF(EQUATIONS_SET%SUBTYPE==EQUATIONS_SET_STATIC_NAVIER_STOKES_SUBTYPE.OR.  &
            & EQUATIONS_SET%SUBTYPE==EQUATIONS_SET_LAPLACE_NAVIER_STOKES_SUBTYPE.OR. &
            & EQUATIONS_SET%SUBTYPE==EQUATIONS_SET_TRANSIENT_NAVIER_STOKES_SUBTYPE.OR. &
            & EQUATIONS_SET%SUBTYPE==EQUATIONS_SET_ALE_NAVIER_STOKES_SUBTYPE) THEN

            IF(STIFFNESS_MATRIX%FIRST_ASSEMBLY) THEN
              IF(STIFFNESS_MATRIX%UPDATE_MATRIX) THEN
                STIFFNESS_MATRIX%ELEMENT_MATRIX%MATRIX(1:mhs_min,1:nhs_min)=(AL_MATRIX(1:mhs_min,1:nhs_min)+ &
                  & AG_MATRIX(1:mhs_min,1:nhs_min)+ALE_MATRIX(1:mhs_min,1:nhs_min))
                STIFFNESS_MATRIX%ELEMENT_MATRIX%MATRIX(1:mhs_min,nhs_min+1:nhs_max)=(BT_MATRIX(1:mhs_min,nhs_min+1:nhs_max))
                DO mhs=mhs_min+1,mhs_max
                  DO nhs=1,nhs_min
                    !Transpose pressure type entries for mass equation  
                    STIFFNESS_MATRIX%ELEMENT_MATRIX%MATRIX(mhs,nhs)=STIFFNESS_MATRIX%ELEMENT_MATRIX%MATRIX(nhs,mhs)
                  END DO
                END DO
              ENDIF
            ENDIF
          ENDIF

          IF(EQUATIONS_SET%SUBTYPE==EQUATIONS_SET_TRANSIENT_NAVIER_STOKES_SUBTYPE.OR. &
            & EQUATIONS_SET%SUBTYPE==EQUATIONS_SET_ALE_NAVIER_STOKES_SUBTYPE) THEN
            IF(DAMPING_MATRIX%UPDATE_MATRIX) THEN
              DAMPING_MATRIX%ELEMENT_MATRIX%MATRIX(1:mhs_min,1:nhs_min)=MT_MATRIX(1:mhs_min,1:nhs_min)
            END IF
          END IF

!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
!!! RIGHT HAND SIDE VECTOR !!!
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

          IF(RHS_VECTOR%FIRST_ASSEMBLY) THEN
            IF(RHS_VECTOR%UPDATE_VECTOR) THEN
              RHS_VECTOR%ELEMENT_VECTOR%VECTOR(1:mhs_max)=RH_VECTOR(1:mhs_max)
            ENDIF
          ENDIF

!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
!!! NONLINEAR VECTOR !!!
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

          IF(NONLINEAR_MATRICES%UPDATE_RESIDUAL) THEN
            NONLINEAR_MATRICES%ELEMENT_RESIDUAL%VECTOR(1:mhs_max)=NL_VECTOR(1:mhs_max)
          END IF

!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
!!! DEFAULT !!!
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

        CASE DEFAULT
          LOCAL_ERROR="Equations set subtype "//TRIM(NUMBER_TO_VSTRING(EQUATIONS_SET%SUBTYPE,"*",ERR,ERROR))// &
            & " is not valid for a Navier-Stokes equation type of a classical field equations set class."
          CALL FLAG_ERROR(LOCAL_ERROR,ERR,ERROR,*999)
        END SELECT
      ELSE
        CALL FLAG_ERROR("Equations set equations is not associated.",ERR,ERROR,*999)
      ENDIF
    ELSE
      CALL FLAG_ERROR("Equations set is not associated.",ERR,ERROR,*999)
    ENDIF
    
    CALL EXITS("NAVIER_STOKES_FINITE_ELEMENT_RESIDUAL_EVALUATE")
    RETURN
999 CALL ERRORS("NAVIER_STOKES_FINITE_ELEMENT_RESIDUAL_EVALUATE",ERR,ERROR)
    CALL EXITS("NAVIER_STOKES_FINITE_ELEMENT_RESIDUAL_EVALUATE")
    RETURN 1
  END SUBROUTINE NAVIER_STOKES_FINITE_ELEMENT_RESIDUAL_EVALUATE

  !
  !================================================================================================================================
  !

  !>Evaluates the Jacobian element stiffness matrices and RHS for a Navier-Stokes equation finite element equations set.
  SUBROUTINE NAVIER_STOKES_FINITE_ELEMENT_JACOBIAN_EVALUATE(EQUATIONS_SET,ELEMENT_NUMBER,ERR,ERROR,*)

    !Argument variables
    TYPE(EQUATIONS_SET_TYPE), POINTER :: EQUATIONS_SET !<A pointer to the equations set to perform the finite element calculations on
    INTEGER(INTG), INTENT(IN) :: ELEMENT_NUMBER !<The element number to calculate
    INTEGER(INTG), INTENT(OUT) :: ERR !<The error code
    TYPE(VARYING_STRING), INTENT(OUT) :: ERROR !<The error string
    !Local Variables
    INTEGER(INTG) ng,mh,mhs,mi,ms,nh,nhs,ni,ns,MESH_COMPONENT1,MESH_COMPONENT2, nhs_max, mhs_max, nhs_min, mhs_min
    REAL(DP) :: JGW,SUM,DXI_DX(3,3),PHIMS,PHINS,MU_PARAM,RHO_PARAM,DPHIMS_DXI(3),DPHINS_DXI(3)
    TYPE(BASIS_TYPE), POINTER :: DEPENDENT_BASIS,DEPENDENT_BASIS1,DEPENDENT_BASIS2,GEOMETRIC_BASIS,INDEPENDENT_BASIS
    TYPE(EQUATIONS_TYPE), POINTER :: EQUATIONS
    TYPE(EQUATIONS_MAPPING_TYPE), POINTER :: EQUATIONS_MAPPING

    TYPE(EQUATIONS_MAPPING_LINEAR_TYPE), POINTER :: LINEAR_MAPPING
    TYPE(EQUATIONS_MAPPING_DYNAMIC_TYPE), POINTER :: DYNAMIC_MAPPING
    TYPE(EQUATIONS_MAPPING_NONLINEAR_TYPE), POINTER :: NONLINEAR_MAPPING

    TYPE(EQUATIONS_MATRICES_TYPE), POINTER :: EQUATIONS_MATRICES
    TYPE(EQUATIONS_MATRICES_LINEAR_TYPE), POINTER :: LINEAR_MATRICES
    TYPE(EQUATIONS_MATRICES_DYNAMIC_TYPE), POINTER :: DYNAMIC_MATRICES
    TYPE(EQUATIONS_MATRICES_NONLINEAR_TYPE), POINTER :: NONLINEAR_MATRICES
    TYPE(EQUATIONS_JACOBIAN_TYPE), POINTER :: JACOBIAN_MATRIX

    TYPE(EQUATIONS_MATRIX_TYPE), POINTER :: STIFFNESS_MATRIX !, DAMPING_MATRIX
    TYPE(FIELD_TYPE), POINTER :: DEPENDENT_FIELD,GEOMETRIC_FIELD,MATERIALS_FIELD,INDEPENDENT_FIELD
    TYPE(FIELD_VARIABLE_TYPE), POINTER :: FIELD_VARIABLE
    TYPE(QUADRATURE_SCHEME_TYPE), POINTER :: QUADRATURE_SCHEME,QUADRATURE_SCHEME1,QUADRATURE_SCHEME2
    TYPE(VARYING_STRING) :: LOCAL_ERROR
    INTEGER(INTG) :: x


    !REAL(DP) :: test(89,89),test2(89,89),scaling,square
    REAL(DP) :: J1_MATRIX(256,256) ! "A" Matrix ("G"radient part) - maximum size allocated
    REAL(DP) :: J2_MATRIX(256,256) ! "A" Matrix ("L"aplace part) - maximum size allocated
    
    REAL(DP) :: U_VALUE(3),W_VALUE(3)
    REAL(DP) :: U_DERIV(3,3)


    CALL ENTERS("NAVIER_STOKES_FINITE_ELEMENT_JACOBIAN_EVALUATE",ERR,ERROR,*999)

    J1_MATRIX=0.0_DP
    J2_MATRIX=0.0_DP

    IF(ASSOCIATED(EQUATIONS_SET)) THEN
      NULLIFY(EQUATIONS)
      EQUATIONS=>EQUATIONS_SET%EQUATIONS
      IF(ASSOCIATED(EQUATIONS)) THEN
        SELECT CASE(EQUATIONS_SET%SUBTYPE)

          CASE(EQUATIONS_SET_STATIC_NAVIER_STOKES_SUBTYPE,EQUATIONS_SET_LAPLACE_NAVIER_STOKES_SUBTYPE, &
            & EQUATIONS_SET_TRANSIENT_NAVIER_STOKES_SUBTYPE,EQUATIONS_SET_ALE_NAVIER_STOKES_SUBTYPE)

!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
!!! SET POINTERS !!!
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

            DEPENDENT_FIELD=>EQUATIONS%INTERPOLATION%DEPENDENT_FIELD
            GEOMETRIC_FIELD=>EQUATIONS%INTERPOLATION%GEOMETRIC_FIELD
            MATERIALS_FIELD=>EQUATIONS%INTERPOLATION%MATERIALS_FIELD
            EQUATIONS_MATRICES=>EQUATIONS%EQUATIONS_MATRICES
            GEOMETRIC_BASIS=>GEOMETRIC_FIELD%DECOMPOSITION%DOMAIN(GEOMETRIC_FIELD%DECOMPOSITION%MESH_COMPONENT_NUMBER)%PTR% &
              & TOPOLOGY%ELEMENTS%ELEMENTS(ELEMENT_NUMBER)%BASIS
            DEPENDENT_BASIS=>DEPENDENT_FIELD%DECOMPOSITION%DOMAIN(DEPENDENT_FIELD%DECOMPOSITION%MESH_COMPONENT_NUMBER)%PTR% &
              & TOPOLOGY%ELEMENTS%ELEMENTS(ELEMENT_NUMBER)%BASIS
            QUADRATURE_SCHEME=>DEPENDENT_BASIS%QUADRATURE%QUADRATURE_SCHEME_MAP(BASIS_DEFAULT_QUADRATURE_SCHEME)%PTR
!            RHS_VECTOR=>EQUATIONS_MATRICES%RHS_VECTOR
            EQUATIONS_MAPPING=>EQUATIONS%EQUATIONS_MAPPING

            SELECT CASE(EQUATIONS_SET%SUBTYPE)
              CASE(EQUATIONS_SET_STATIC_NAVIER_STOKES_SUBTYPE,EQUATIONS_SET_LAPLACE_NAVIER_STOKES_SUBTYPE)
                LINEAR_MATRICES=>EQUATIONS_MATRICES%LINEAR_MATRICES
                NONLINEAR_MATRICES=>EQUATIONS_MATRICES%NONLINEAR_MATRICES
                JACOBIAN_MATRIX=>NONLINEAR_MATRICES%JACOBIAN
                STIFFNESS_MATRIX=>LINEAR_MATRICES%MATRICES(1)%PTR
                LINEAR_MAPPING=>EQUATIONS_MAPPING%LINEAR_MAPPING
                NONLINEAR_MAPPING=>EQUATIONS_MAPPING%NONLINEAR_MAPPING
                FIELD_VARIABLE=>NONLINEAR_MAPPING%RESIDUAL_VARIABLE
!               SOURCE_VECTOR=>EQUATIONS_MATRICES%SOURCE_VECTOR
                STIFFNESS_MATRIX%ELEMENT_MATRIX%MATRIX=0.0_DP
                NONLINEAR_MATRICES%ELEMENT_RESIDUAL%VECTOR=0.0_DP
              CASE(EQUATIONS_SET_TRANSIENT_NAVIER_STOKES_SUBTYPE)
                NONLINEAR_MAPPING=>EQUATIONS_MAPPING%NONLINEAR_MAPPING
 !              DEPENDENT_VARIABLE=>NONLINEAR_MAPPING%RESIDUAL_VARIABLE
 !              GEOMETRIC_VARIABLE=>GEOMETRIC_FIELD%VARIABLE_TYPE_MAP(FIELD_U_VARIABLE_TYPE)%PTR
                NONLINEAR_MATRICES=>EQUATIONS_MATRICES%NONLINEAR_MATRICES
                JACOBIAN_MATRIX=>NONLINEAR_MATRICES%JACOBIAN
                JACOBIAN_MATRIX%ELEMENT_JACOBIAN%MATRIX=0.0_DP
                DYNAMIC_MATRICES=>EQUATIONS_MATRICES%DYNAMIC_MATRICES
                DYNAMIC_MAPPING=>EQUATIONS_MAPPING%DYNAMIC_MAPPING
                FIELD_VARIABLE=>NONLINEAR_MAPPING%RESIDUAL_VARIABLE
                LINEAR_MAPPING=>EQUATIONS_MAPPING%LINEAR_MAPPING
              CASE(EQUATIONS_SET_ALE_NAVIER_STOKES_SUBTYPE)
                INDEPENDENT_FIELD=>EQUATIONS%INTERPOLATION%INDEPENDENT_FIELD
                INDEPENDENT_BASIS=>INDEPENDENT_FIELD%DECOMPOSITION%DOMAIN(INDEPENDENT_FIELD%DECOMPOSITION%MESH_COMPONENT_NUMBER)% & 
                  & PTR%TOPOLOGY%ELEMENTS%ELEMENTS(ELEMENT_NUMBER)%BASIS

                NONLINEAR_MAPPING=>EQUATIONS_MAPPING%NONLINEAR_MAPPING
 !              DEPENDENT_VARIABLE=>NONLINEAR_MAPPING%RESIDUAL_VARIABLE
 !              GEOMETRIC_VARIABLE=>GEOMETRIC_FIELD%VARIABLE_TYPE_MAP(FIELD_U_VARIABLE_TYPE)%PTR
                NONLINEAR_MATRICES=>EQUATIONS_MATRICES%NONLINEAR_MATRICES
                JACOBIAN_MATRIX=>NONLINEAR_MATRICES%JACOBIAN
                JACOBIAN_MATRIX%ELEMENT_JACOBIAN%MATRIX=0.0_DP
                DYNAMIC_MATRICES=>EQUATIONS_MATRICES%DYNAMIC_MATRICES
                DYNAMIC_MAPPING=>EQUATIONS_MAPPING%DYNAMIC_MAPPING
                FIELD_VARIABLE=>NONLINEAR_MAPPING%RESIDUAL_VARIABLE
                LINEAR_MAPPING=>EQUATIONS_MAPPING%LINEAR_MAPPING

                CALL FIELD_INTERPOLATION_PARAMETERS_ELEMENT_GET(FIELD_MESH_VELOCITY_SET_TYPE,ELEMENT_NUMBER,EQUATIONS% & 
                  & INTERPOLATION%INDEPENDENT_INTERP_PARAMETERS,ERR,ERROR,*999)
              CASE DEFAULT
                LOCAL_ERROR="Equations set subtype "//TRIM(NUMBER_TO_VSTRING(EQUATIONS_SET%SUBTYPE,"*",ERR,ERROR))// &
                  & " is not valid for a Navier-Stokes fluid type of a fluid mechanics equations set class."
                CALL FLAG_ERROR(LOCAL_ERROR,ERR,ERROR,*999)
            END SELECT

!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
!!! LOOP OVER GAUSS POINTS !!!
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

            CALL FIELD_INTERPOLATION_PARAMETERS_ELEMENT_GET(FIELD_VALUES_SET_TYPE,ELEMENT_NUMBER,EQUATIONS%INTERPOLATION% &
              & DEPENDENT_INTERP_PARAMETERS,ERR,ERROR,*999)
            CALL FIELD_INTERPOLATION_PARAMETERS_ELEMENT_GET(FIELD_VALUES_SET_TYPE,ELEMENT_NUMBER,EQUATIONS%INTERPOLATION% &
              & GEOMETRIC_INTERP_PARAMETERS,ERR,ERROR,*999)
            CALL FIELD_INTERPOLATION_PARAMETERS_ELEMENT_GET(FIELD_VALUES_SET_TYPE,ELEMENT_NUMBER,EQUATIONS%INTERPOLATION% &
              & MATERIALS_INTERP_PARAMETERS,ERR,ERROR,*999)
 
            DO ng=1,QUADRATURE_SCHEME%NUMBER_OF_GAUSS
 !               CALL FIELD_INTERPOLATE_GAUSS(NO_PART_DERIV,BASIS_DEFAULT_QUADRATURE_SCHEME,ng,EQUATIONS%INTERPOLATION% &
              CALL FIELD_INTERPOLATE_GAUSS(FIRST_PART_DERIV,BASIS_DEFAULT_QUADRATURE_SCHEME,ng,EQUATIONS%INTERPOLATION% &
                & DEPENDENT_INTERP_POINT,ERR,ERROR,*999)
              CALL FIELD_INTERPOLATE_GAUSS(FIRST_PART_DERIV,BASIS_DEFAULT_QUADRATURE_SCHEME,ng,EQUATIONS%INTERPOLATION% &
                & GEOMETRIC_INTERP_POINT,ERR,ERROR,*999)
              CALL FIELD_INTERPOLATED_POINT_METRICS_CALCULATE(GEOMETRIC_BASIS%NUMBER_OF_XI,EQUATIONS%INTERPOLATION% &
                & GEOMETRIC_INTERP_POINT_METRICS,ERR,ERROR,*999)
              CALL FIELD_INTERPOLATE_GAUSS(NO_PART_DERIV,BASIS_DEFAULT_QUADRATURE_SCHEME,ng,EQUATIONS%INTERPOLATION% &
                & MATERIALS_INTERP_POINT,ERR,ERROR,*999)

              IF(EQUATIONS_SET%SUBTYPE==EQUATIONS_SET_ALE_NAVIER_STOKES_SUBTYPE) THEN
                CALL FIELD_INTERPOLATE_GAUSS(FIRST_PART_DERIV,BASIS_DEFAULT_QUADRATURE_SCHEME,ng,EQUATIONS%INTERPOLATION% &
                  & INDEPENDENT_INTERP_POINT,ERR,ERROR,*999)
                  W_VALUE(1)=EQUATIONS%INTERPOLATION%INDEPENDENT_INTERP_POINT%VALUES(1,NO_PART_DERIV)
                  W_VALUE(2)=EQUATIONS%INTERPOLATION%INDEPENDENT_INTERP_POINT%VALUES(2,NO_PART_DERIV)
                  IF(FIELD_VARIABLE%NUMBER_OF_COMPONENTS==4) THEN
                    W_VALUE(3)=EQUATIONS%INTERPOLATION%INDEPENDENT_INTERP_POINT%VALUES(3,NO_PART_DERIV)
                  END IF 
              ELSE
                W_VALUE=0.0_DP
              END IF

              !Define MU_PARAM, viscosity=1
              MU_PARAM=EQUATIONS%INTERPOLATION%MATERIALS_INTERP_POINT%VALUES(1,NO_PART_DERIV)
              !Define RHO_PARAM, density=2
              RHO_PARAM=EQUATIONS%INTERPOLATION%MATERIALS_INTERP_POINT%VALUES(2,NO_PART_DERIV)
              U_VALUE(1)=EQUATIONS%INTERPOLATION%DEPENDENT_INTERP_POINT%VALUES(1,NO_PART_DERIV)
              U_VALUE(2)=EQUATIONS%INTERPOLATION%DEPENDENT_INTERP_POINT%VALUES(2,NO_PART_DERIV)
              U_DERIV(1,1)=EQUATIONS%INTERPOLATION%DEPENDENT_INTERP_POINT%VALUES(1,PART_DERIV_S1)
              U_DERIV(1,2)=EQUATIONS%INTERPOLATION%DEPENDENT_INTERP_POINT%VALUES(1,PART_DERIV_S2)
              U_DERIV(2,1)=EQUATIONS%INTERPOLATION%DEPENDENT_INTERP_POINT%VALUES(2,PART_DERIV_S1)
              U_DERIV(2,2)=EQUATIONS%INTERPOLATION%DEPENDENT_INTERP_POINT%VALUES(2,PART_DERIV_S2)
 
              IF(FIELD_VARIABLE%NUMBER_OF_COMPONENTS==4) THEN
                U_VALUE(3)=EQUATIONS%INTERPOLATION%DEPENDENT_INTERP_POINT%VALUES(3,NO_PART_DERIV)
                U_DERIV(3,1)=EQUATIONS%INTERPOLATION%DEPENDENT_INTERP_POINT%VALUES(3,PART_DERIV_S1)
                U_DERIV(3,2)=EQUATIONS%INTERPOLATION%DEPENDENT_INTERP_POINT%VALUES(3,PART_DERIV_S2)
                U_DERIV(3,3)=EQUATIONS%INTERPOLATION%DEPENDENT_INTERP_POINT%VALUES(3,PART_DERIV_S3)
                U_DERIV(1,3)=EQUATIONS%INTERPOLATION%DEPENDENT_INTERP_POINT%VALUES(1,PART_DERIV_S3)
                U_DERIV(2,3)=EQUATIONS%INTERPOLATION%DEPENDENT_INTERP_POINT%VALUES(2,PART_DERIV_S3) 
              ELSE
                U_VALUE(3)=0.0_DP
                U_DERIV(3,1)=0.0_DP
                U_DERIV(3,2)=0.0_DP
                U_DERIV(3,3)=0.0_DP
                U_DERIV(1,3)=0.0_DP
                U_DERIV(2,3)=0.0_DP
              END IF
 
 !             WRITE(*,*)'U_VALUE/DERIV',U_VALUE(1),U_DERIV(1,1),U_VALUE(2),U_DERIV(2,1),U_VALUE(3),U_DERIV(3,1)
 
        !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
        !!! CALCULATE PARTIAL MATRICES !!!
        !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
 
              !Here W_VALUES must be ZERO if ALE part of linear matrix
              W_VALUE=0.0_DP

              IF(EQUATIONS_SET%SUBTYPE==EQUATIONS_SET_STATIC_NAVIER_STOKES_SUBTYPE.OR.  &
                & EQUATIONS_SET%SUBTYPE==EQUATIONS_SET_LAPLACE_NAVIER_STOKES_SUBTYPE.OR. &
                & EQUATIONS_SET%SUBTYPE==EQUATIONS_SET_TRANSIENT_NAVIER_STOKES_SUBTYPE.OR. &
                & EQUATIONS_SET%SUBTYPE==EQUATIONS_SET_ALE_NAVIER_STOKES_SUBTYPE) THEN
                !Loop over field components
                mhs=0
 
                DO mh=1,(FIELD_VARIABLE%NUMBER_OF_COMPONENTS-1)
                  MESH_COMPONENT1=FIELD_VARIABLE%COMPONENTS(mh)%MESH_COMPONENT_NUMBER
                  DEPENDENT_BASIS1=>DEPENDENT_FIELD%DECOMPOSITION%DOMAIN(MESH_COMPONENT1)%PTR% &
                    & TOPOLOGY%ELEMENTS%ELEMENTS(ELEMENT_NUMBER)%BASIS
                  QUADRATURE_SCHEME1=>DEPENDENT_BASIS1%QUADRATURE%QUADRATURE_SCHEME_MAP(BASIS_DEFAULT_QUADRATURE_SCHEME)%PTR
                  JGW=EQUATIONS%INTERPOLATION%GEOMETRIC_INTERP_POINT_METRICS%JACOBIAN*QUADRATURE_SCHEME1%GAUSS_WEIGHTS(ng)
                  DO ms=1,DEPENDENT_BASIS1%NUMBER_OF_ELEMENT_PARAMETERS
                    mhs=mhs+1
                    nhs=0
                    IF(JACOBIAN_MATRIX%UPDATE_JACOBIAN) THEN
                      !Loop over element columns
                      DO nh=1,(FIELD_VARIABLE%NUMBER_OF_COMPONENTS-1)
                        MESH_COMPONENT2=FIELD_VARIABLE%COMPONENTS(nh)%MESH_COMPONENT_NUMBER
                        DEPENDENT_BASIS2=>DEPENDENT_FIELD%DECOMPOSITION%DOMAIN(MESH_COMPONENT2)%PTR% &
                          & TOPOLOGY%ELEMENTS%ELEMENTS(ELEMENT_NUMBER)%BASIS
                        QUADRATURE_SCHEME2=>DEPENDENT_BASIS2%QUADRATURE%QUADRATURE_SCHEME_MAP&
                          &(BASIS_DEFAULT_QUADRATURE_SCHEME)%PTR
                        ! JGW=EQUATIONS%INTERPOLATION%GEOMETRIC_INTERP_POINT_METRICS%JACOBIAN*QUADRATURE_SCHEME2%&
                        ! &GAUSS_WEIGHTS(ng)                        
 
                        DO ns=1,DEPENDENT_BASIS2%NUMBER_OF_ELEMENT_PARAMETERS
                          nhs=nhs+1
 
              !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
              !!! PRECONDITIONS !!!
              !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
 
                          DO ni=1,DEPENDENT_BASIS2%NUMBER_OF_XI
                            DO mi=1,DEPENDENT_BASIS1%NUMBER_OF_XI
                              DXI_DX(mi,ni)=EQUATIONS%INTERPOLATION%GEOMETRIC_INTERP_POINT_METRICS%DXI_DX(mi,ni)
                            END DO
                            DPHIMS_DXI(ni)=QUADRATURE_SCHEME1%GAUSS_BASIS_FNS(ms,PARTIAL_DERIVATIVE_FIRST_DERIVATIVE_MAP(ni),ng)
                            DPHINS_DXI(ni)=QUADRATURE_SCHEME2%GAUSS_BASIS_FNS(ns,PARTIAL_DERIVATIVE_FIRST_DERIVATIVE_MAP(ni),ng)
                          END DO !ni
                            PHIMS=QUADRATURE_SCHEME1%GAUSS_BASIS_FNS(ms,NO_PART_DERIV,ng)
                            PHINS=QUADRATURE_SCHEME2%GAUSS_BASIS_FNS(ns,NO_PART_DERIV,ng)
 
              !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
              !!! J1 ONLY !!!
              !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
 
                          IF(JACOBIAN_MATRIX%UPDATE_JACOBIAN) THEN
                            SUM=PHINS*U_DERIV(mh,nh)*PHIMS*RHO_PARAM
                            !Calculate MATRIX  
                            J1_MATRIX(mhs,nhs)=J1_MATRIX(mhs,nhs)+SUM*JGW
 
             !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
              !!! J2 ONLY !!!
              !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
 
                            IF(nh==mh) THEN 
                              SUM=0.0_DP
                              !Calculate SUM 
                              DO x=1,DEPENDENT_BASIS1%NUMBER_OF_XI
                                DO mi=1,DEPENDENT_BASIS2%NUMBER_OF_XI
                                  SUM=SUM+RHO_PARAM*(U_VALUE(x)-W_VALUE(x))*DPHINS_DXI(mi)*DXI_DX(mi,x)*PHIMS
                                ENDDO !mi
                              ENDDO !x
                              !Calculate MATRIX
                              J2_MATRIX(mhs,nhs)=J2_MATRIX(mhs,nhs)+SUM*JGW
                            END IF
                          END IF
                        ENDDO !ns    
                      ENDDO !nh
                    ENDIF
                      !!! GO TO MATRIX ASSEMBLY !!!
                  ENDDO !ms
                ENDDO !mh
              END IF
            ENDDO !ng
 
 
 !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
 !!! ASSEMBLE STIFFNESS AND VECTORS !!!
 !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
 
            mhs_min=mhs
            mhs_max=nhs
            nhs_min=mhs
            nhs_max=nhs
 
            IF(EQUATIONS_SET%SUBTYPE==EQUATIONS_SET_STATIC_NAVIER_STOKES_SUBTYPE.OR.  &
              & EQUATIONS_SET%SUBTYPE==EQUATIONS_SET_LAPLACE_NAVIER_STOKES_SUBTYPE.OR. &
              & EQUATIONS_SET%SUBTYPE==EQUATIONS_SET_TRANSIENT_NAVIER_STOKES_SUBTYPE.OR. &
              & EQUATIONS_SET%SUBTYPE==EQUATIONS_SET_ALE_NAVIER_STOKES_SUBTYPE) THEN
 
        !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
        !!! JACOBIAN MATRIX !!!
        !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
 
              IF(JACOBIAN_MATRIX%UPDATE_JACOBIAN) THEN
                JACOBIAN_MATRIX%ELEMENT_JACOBIAN%MATRIX(1:mhs_min,1:nhs_min)=J1_MATRIX(1:mhs_min,1:nhs_min)+ & 
                  & J2_MATRIX(1:mhs_min,1:nhs_min)
              END IF
            ENDIF
 
 !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
 !!! DEFAULT !!!
 !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

          CASE DEFAULT
            LOCAL_ERROR="Equations set subtype "//TRIM(NUMBER_TO_VSTRING(EQUATIONS_SET%SUBTYPE,"*",ERR,ERROR))// &
              & " is not valid for a Navier-Stokes equation type of a classical field equations set class."
            CALL FLAG_ERROR(LOCAL_ERROR,ERR,ERROR,*999)
        END SELECT
      ELSE
        CALL FLAG_ERROR("Equations set equations is not associated.",ERR,ERROR,*999)
      ENDIF
    ELSE
      CALL FLAG_ERROR("Equations set is not associated.",ERR,ERROR,*999)
    ENDIF
       
    CALL EXITS("NAVIER_STOKES_FINITE_ELEMENT_JACOBIAN_EVALUATE")
    RETURN
999 CALL ERRORS("NAVIER_STOKES_FINITE_ELEMENT_JACOBIAN_EVALUATE",ERR,ERROR)
    CALL EXITS("NAVIER_STOKES_FINITE_ELEMENT_JACOBIAN_EVALUATE")
    RETURN 1
  END SUBROUTINE NAVIER_STOKES_FINITE_ELEMENT_JACOBIAN_EVALUATE


  !
  !================================================================================================================================
  !

  !>Sets up the Navier-Stokes problem post solve.
  SUBROUTINE NAVIER_STOKES_POST_SOLVE(CONTROL_LOOP,SOLVER,ERR,ERROR,*)

    !Argument variables
    TYPE(CONTROL_LOOP_TYPE), POINTER :: CONTROL_LOOP !<A pointer to the control loop to solve.
    TYPE(SOLVER_TYPE), POINTER :: SOLVER!<A pointer to the solver
    INTEGER(INTG), INTENT(OUT) :: ERR !<The error code
    TYPE(VARYING_STRING), INTENT(OUT) :: ERROR !<The error string
    !Local Variables
    TYPE(SOLVER_TYPE), POINTER :: SOLVER2 !<A pointer to the solver
    TYPE(VARYING_STRING) :: LOCAL_ERROR

    CALL ENTERS("NAVIER_STOKES_POST_SOLVE",ERR,ERROR,*999)
    NULLIFY(SOLVER2)

    IF(ASSOCIATED(CONTROL_LOOP)) THEN
      IF(ASSOCIATED(SOLVER)) THEN
        IF(ASSOCIATED(CONTROL_LOOP%PROBLEM)) THEN 
          SELECT CASE(CONTROL_LOOP%PROBLEM%SUBTYPE)
            CASE(PROBLEM_STATIC_NAVIER_STOKES_SUBTYPE,PROBLEM_LAPLACE_NAVIER_STOKES_SUBTYPE)
              ! do nothing ???
            CASE(PROBLEM_TRANSIENT_NAVIER_STOKES_SUBTYPE)
              CALL NAVIER_STOKES_POST_SOLVE_OUTPUT_DATA(CONTROL_LOOP,SOLVER,ERR,ERROR,*999)
            CASE(PROBLEM_ALE_NAVIER_STOKES_SUBTYPE)
              !Post solve for the linear solver
              IF(SOLVER%SOLVE_TYPE==SOLVER_LINEAR_TYPE) THEN
                CALL WRITE_STRING(GENERAL_OUTPUT_TYPE,"Mesh movement post solve... ",ERR,ERROR,*999)
                CALL SOLVERS_SOLVER_GET(SOLVER%SOLVERS,2,SOLVER2,ERR,ERROR,*999)
                IF(ASSOCIATED(SOLVER2%DYNAMIC_SOLVER)) THEN
                  SOLVER2%DYNAMIC_SOLVER%ALE=.TRUE.
                ELSE  
                  CALL FLAG_ERROR("Dynamic solver is not associated for ALE problem.",ERR,ERROR,*999)
                END IF
              !Post solve for the linear solver
              ELSE IF(SOLVER%SOLVE_TYPE==SOLVER_DYNAMIC_TYPE) THEN
                CALL WRITE_STRING(GENERAL_OUTPUT_TYPE,"ALE Navier-Stokes post solve... ",ERR,ERROR,*999)
                CALL NAVIER_STOKES_POST_SOLVE_OUTPUT_DATA(CONTROL_LOOP,SOLVER,ERR,ERROR,*999)
              END IF
            CASE DEFAULT
              LOCAL_ERROR="Problem subtype "//TRIM(NUMBER_TO_VSTRING(CONTROL_LOOP%PROBLEM%SUBTYPE,"*",ERR,ERROR))// &
                & " is not valid for a Navier-Stokes fluid type of a fluid mechanics problem class."
              CALL FLAG_ERROR(LOCAL_ERROR,ERR,ERROR,*999)
          END SELECT
        ELSE
          CALL FLAG_ERROR("Problem is not associated.",ERR,ERROR,*999)
        ENDIF
      ELSE
        CALL FLAG_ERROR("Solver is not associated.",ERR,ERROR,*999)
      ENDIF
    ELSE
      CALL FLAG_ERROR("Control loop is not associated.",ERR,ERROR,*999)
    ENDIF

    CALL EXITS("NAVIER_STOKES_POST_SOLVE")
    RETURN
999 CALL ERRORS("NAVIER_STOKES_POST_SOLVE",ERR,ERROR)
    CALL EXITS("NAVIER_STOKES_POST_SOLVE")
    RETURN 1
  END SUBROUTINE NAVIER_STOKES_POST_SOLVE

  !
  !================================================================================================================================
  !


  !>Sets up the Navier-Stokes problem pre solve.
  SUBROUTINE NAVIER_STOKES_PRE_SOLVE(CONTROL_LOOP,SOLVER,ERR,ERROR,*)

    !Argument variables
    TYPE(CONTROL_LOOP_TYPE), POINTER :: CONTROL_LOOP !<A pointer to the control loop to solve.
    TYPE(SOLVER_TYPE), POINTER :: SOLVER !<A pointer to the solver
!     TYPE(SOLVER_EQUATIONS_TYPE), POINTER :: SOLVER_EQUATIONS  !<A pointer to the solver equations
!     TYPE(EQUATIONS_SET_TYPE), POINTER :: EQUATIONS_SET !<A pointer to the equations set
    INTEGER(INTG), INTENT(OUT) :: ERR !<The error code
    TYPE(VARYING_STRING), INTENT(OUT) :: ERROR !<The error string
    !Local Variables
    TYPE(SOLVER_TYPE), POINTER :: SOLVER2 !<A pointer to the solvers
    TYPE(VARYING_STRING) :: LOCAL_ERROR

    CALL ENTERS("NAVIER_STOKES_PRE_SOLVE",ERR,ERROR,*999)
    NULLIFY(SOLVER2)
 
    IF(ASSOCIATED(CONTROL_LOOP)) THEN
      IF(ASSOCIATED(SOLVER)) THEN
        IF(ASSOCIATED(CONTROL_LOOP%PROBLEM)) THEN
          SELECT CASE(CONTROL_LOOP%PROBLEM%SUBTYPE)
            CASE(PROBLEM_STATIC_NAVIER_STOKES_SUBTYPE,PROBLEM_LAPLACE_NAVIER_STOKES_SUBTYPE)
              ! do nothing ???
            CASE(PROBLEM_TRANSIENT_NAVIER_STOKES_SUBTYPE)
              ! do nothing ???
                CALL NAVIER_STOKES_PRE_SOLVE_UPDATE_BOUNDARY_CONDITIONS(CONTROL_LOOP,SOLVER,ERR,ERROR,*999)
            CASE(PROBLEM_ALE_NAVIER_STOKES_SUBTYPE)
              !Pre solve for the linear solver
              IF(SOLVER%SOLVE_TYPE==SOLVER_LINEAR_TYPE) THEN
                CALL WRITE_STRING(GENERAL_OUTPUT_TYPE,"Mesh movement pre solve... ",ERR,ERROR,*999)
                !Update boundary conditions for mesh-movement
                CALL NAVIER_STOKES_PRE_SOLVE_UPDATE_BOUNDARY_CONDITIONS(CONTROL_LOOP,SOLVER,ERR,ERROR,*999)
                CALL SOLVERS_SOLVER_GET(SOLVER%SOLVERS,2,SOLVER2,ERR,ERROR,*999)
                IF(ASSOCIATED(SOLVER2%DYNAMIC_SOLVER)) THEN
                  SOLVER2%DYNAMIC_SOLVER%ALE=.FALSE.
                ELSE  
                  CALL FLAG_ERROR("Dynamic solver is not associated for ALE problem.",ERR,ERROR,*999)
                END IF
                !Update material properties for Laplace mesh movement
                CALL NAVIER_STOKES_PRE_SOLVE_ALE_UPDATE_PARAMETERS(CONTROL_LOOP,SOLVER,ERR,ERROR,*999)
              !Pre solve for the linear solver
              ELSE IF(SOLVER%SOLVE_TYPE==SOLVER_DYNAMIC_TYPE) THEN
                CALL WRITE_STRING(GENERAL_OUTPUT_TYPE,"ALE Navier-Stokes pre solve... ",ERR,ERROR,*999)
                IF(SOLVER%DYNAMIC_SOLVER%ALE) THEN
                  !First update mesh and calculates boundary velocity values
                  CALL NAVIER_STOKES_PRE_SOLVE_ALE_UPDATE_MESH(CONTROL_LOOP,SOLVER,ERR,ERROR,*999)
                  !Then apply both normal and moving mesh boundary conditions
                  CALL NAVIER_STOKES_PRE_SOLVE_UPDATE_BOUNDARY_CONDITIONS(CONTROL_LOOP,SOLVER,ERR,ERROR,*999)
                ELSE  
                  CALL FLAG_ERROR("Mesh motion calculation not successful for ALE problem.",ERR,ERROR,*999)
                END IF
              ELSE  
                CALL FLAG_ERROR("Solver type is not associated for ALE problem.",ERR,ERROR,*999)
              END IF
            CASE DEFAULT
              LOCAL_ERROR="Problem subtype "//TRIM(NUMBER_TO_VSTRING(CONTROL_LOOP%PROBLEM%SUBTYPE,"*",ERR,ERROR))// &
                & " is not valid for a Navier-Stokes fluid type of a fluid mechanics problem class."
              CALL FLAG_ERROR(LOCAL_ERROR,ERR,ERROR,*999)
          END SELECT
        ELSE
          CALL FLAG_ERROR("Problem is not associated.",ERR,ERROR,*999)
        ENDIF
      ELSE
        CALL FLAG_ERROR("Solver is not associated.",ERR,ERROR,*999)
      ENDIF
    ELSE
      CALL FLAG_ERROR("Control loop is not associated.",ERR,ERROR,*999)
    ENDIF

    CALL EXITS("NAVIER_STOKES_PRE_SOLVE")
    RETURN
999 CALL ERRORS("NAVIER_STOKES_PRE_SOLVE",ERR,ERROR)
    CALL EXITS("NAVIER_STOKES_PRE_SOLVE")
    RETURN 1
  END SUBROUTINE NAVIER_STOKES_PRE_SOLVE
  !
  !================================================================================================================================
  !
 
  !>Update boundary conditions for Navier-Stokes flow pre solve
  SUBROUTINE NAVIER_STOKES_PRE_SOLVE_UPDATE_BOUNDARY_CONDITIONS(CONTROL_LOOP,SOLVER,ERR,ERROR,*)

    !Argument variables
    TYPE(CONTROL_LOOP_TYPE), POINTER :: CONTROL_LOOP !<A pointer to the control loop to solve.
    TYPE(SOLVER_TYPE), POINTER :: SOLVER !<A pointer to the solver
    INTEGER(INTG), INTENT(OUT) :: ERR !<The error code
    TYPE(VARYING_STRING), INTENT(OUT) :: ERROR !<The error string
    !Local Variables
    TYPE(SOLVER_EQUATIONS_TYPE), POINTER :: SOLVER_EQUATIONS  !<A pointer to the solver equations
    TYPE(SOLVER_MAPPING_TYPE), POINTER :: SOLVER_MAPPING !<A pointer to the solver mapping
    TYPE(EQUATIONS_SET_TYPE), POINTER :: EQUATIONS_SET !<A pointer to the equations set
    TYPE(EQUATIONS_TYPE), POINTER :: EQUATIONS
    TYPE(VARYING_STRING) :: LOCAL_ERROR
    TYPE(BOUNDARY_CONDITIONS_VARIABLE_TYPE), POINTER :: BOUNDARY_CONDITIONS_VARIABLE
    TYPE(BOUNDARY_CONDITIONS_TYPE), POINTER :: BOUNDARY_CONDITIONS

    REAL(DP) :: CURRENT_TIME,TIME_INCREMENT,DISPLACEMENT_VALUE

    INTEGER(INTG) :: NUMBER_OF_DIMENSIONS,BOUNDARY_CONDITION_CHECK_VARIABLE
    INTEGER(INTG) :: equations_row_number
    REAL(DP), POINTER :: MESH_VELOCITY_VALUES(:) 
    REAL(DP), POINTER :: BOUNDARY_VALUES(:)

    CALL ENTERS("NAVIER_STOKES_PRE_SOLVE_UPDATE_BOUNDARY_CONDITIONS",ERR,ERROR,*999)

    IF(ASSOCIATED(CONTROL_LOOP)) THEN
      CALL CONTROL_LOOP_CURRENT_TIMES_GET(CONTROL_LOOP,CURRENT_TIME,TIME_INCREMENT,ERR,ERROR,*999)
!       write(*,*)'CURRENT_TIME = ',CURRENT_TIME
!       write(*,*)'TIME_INCREMENT = ',TIME_INCREMENT
      IF(ASSOCIATED(SOLVER)) THEN
        IF(ASSOCIATED(CONTROL_LOOP%PROBLEM)) THEN
          SELECT CASE(CONTROL_LOOP%PROBLEM%SUBTYPE)
            CASE(PROBLEM_STATIC_NAVIER_STOKES_SUBTYPE,PROBLEM_LAPLACE_NAVIER_STOKES_SUBTYPE)
              ! do nothing ???
            CASE(PROBLEM_TRANSIENT_NAVIER_STOKES_SUBTYPE)
              ! do nothing ???
            CASE(PROBLEM_ALE_NAVIER_STOKES_SUBTYPE)
              !Pre solve for the linear solver
              IF(SOLVER%SOLVE_TYPE==SOLVER_LINEAR_TYPE) THEN
                CALL WRITE_STRING(GENERAL_OUTPUT_TYPE,"Mesh movement change boundary conditions... ",ERR,ERROR,*999)
                SOLVER_EQUATIONS=>SOLVER%SOLVER_EQUATIONS
                IF(ASSOCIATED(SOLVER_EQUATIONS)) THEN
                  SOLVER_MAPPING=>SOLVER_EQUATIONS%SOLVER_MAPPING
                  EQUATIONS=>SOLVER_MAPPING%EQUATIONS_SET_TO_SOLVER_MAP(1)%EQUATIONS
                  IF(ASSOCIATED(EQUATIONS)) THEN
                    EQUATIONS_SET=>EQUATIONS%EQUATIONS_SET
                    IF(ASSOCIATED(EQUATIONS_SET)) THEN
                      BOUNDARY_CONDITIONS=>EQUATIONS_SET%BOUNDARY_CONDITIONS
                      IF(ASSOCIATED(BOUNDARY_CONDITIONS)) THEN
                        BOUNDARY_CONDITIONS_VARIABLE=>BOUNDARY_CONDITIONS% & 
                          & BOUNDARY_CONDITIONS_VARIABLE_TYPE_MAP(FIELD_U_VARIABLE_TYPE)%PTR
                        IF(ASSOCIATED(BOUNDARY_CONDITIONS_VARIABLE)) THEN

                          CALL FIELD_NUMBER_OF_COMPONENTS_GET(EQUATIONS_SET%GEOMETRY%GEOMETRIC_FIELD,FIELD_U_VARIABLE_TYPE, &
                            & NUMBER_OF_DIMENSIONS,ERR,ERROR,*999)

                          CALL FIELD_PARAMETER_SET_DATA_GET(EQUATIONS_SET%INDEPENDENT%INDEPENDENT_FIELD,FIELD_U_VARIABLE_TYPE, & 
                            & FIELD_BOUNDARY_SET_TYPE,BOUNDARY_VALUES,ERR,ERROR,*999)
                          CALL FLUID_MECHANICS_IO_READ_BOUNDARY_CONDITIONS(SOLVER_LINEAR_TYPE,BOUNDARY_VALUES, & 
                            & NUMBER_OF_DIMENSIONS,BOUNDARY_CONDITION_MOVED_WALL,CURRENT_TIME)

                          DO equations_row_number=1,EQUATIONS%EQUATIONS_MAPPING%TOTAL_NUMBER_OF_ROWS
                            BOUNDARY_CONDITION_CHECK_VARIABLE=BOUNDARY_CONDITIONS_VARIABLE% & 
                              & GLOBAL_BOUNDARY_CONDITIONS(equations_row_number)
                            IF(BOUNDARY_CONDITION_CHECK_VARIABLE==BOUNDARY_CONDITION_MOVED_WALL) THEN
                              CALL FIELD_PARAMETER_SET_UPDATE_LOCAL_DOF(EQUATIONS_SET%DEPENDENT%DEPENDENT_FIELD, & 
                                & FIELD_U_VARIABLE_TYPE,FIELD_VALUES_SET_TYPE,equations_row_number, & 
                                & BOUNDARY_VALUES(equations_row_number),ERR,ERROR,*999)
                            END IF
                          END DO
!This part should be read in out of a file eventually
                        ELSE
                          CALL FLAG_ERROR("Boundary condition variable is not associated.",ERR,ERROR,*999)
                        END IF
                      ELSE
                        CALL FLAG_ERROR("Boundary conditions are not associated.",ERR,ERROR,*999)
                      END IF
                    ELSE
                      CALL FLAG_ERROR("Equations set is not associated.",ERR,ERROR,*999)
                    END IF
                  ELSE
                    CALL FLAG_ERROR("Equations are not associated.",ERR,ERROR,*999)
                  END IF                
                ELSE
                  CALL FLAG_ERROR("Solver equations are not associated.",ERR,ERROR,*999)
                END IF  
                CALL FIELD_PARAMETER_SET_UPDATE_START(EQUATIONS_SET%DEPENDENT%DEPENDENT_FIELD,FIELD_U_VARIABLE_TYPE, & 
                  & FIELD_VALUES_SET_TYPE,ERR,ERROR,*999)
                CALL FIELD_PARAMETER_SET_UPDATE_FINISH(EQUATIONS_SET%DEPENDENT%DEPENDENT_FIELD,FIELD_U_VARIABLE_TYPE, & 
                  & FIELD_VALUES_SET_TYPE,ERR,ERROR,*999)

              !Pre solve for the dynamic solver
              ELSE IF(SOLVER%SOLVE_TYPE==SOLVER_DYNAMIC_TYPE) THEN
               CALL WRITE_STRING(GENERAL_OUTPUT_TYPE,"Mesh movement change boundary conditions... ",ERR,ERROR,*999)
                SOLVER_EQUATIONS=>SOLVER%SOLVER_EQUATIONS
                IF(ASSOCIATED(SOLVER_EQUATIONS)) THEN
                  SOLVER_MAPPING=>SOLVER_EQUATIONS%SOLVER_MAPPING
                  EQUATIONS=>SOLVER_MAPPING%EQUATIONS_SET_TO_SOLVER_MAP(1)%EQUATIONS
                  IF(ASSOCIATED(EQUATIONS)) THEN
                    EQUATIONS_SET=>EQUATIONS%EQUATIONS_SET
                    IF(ASSOCIATED(EQUATIONS_SET)) THEN
                      BOUNDARY_CONDITIONS=>EQUATIONS_SET%BOUNDARY_CONDITIONS
                      IF(ASSOCIATED(BOUNDARY_CONDITIONS)) THEN
                        BOUNDARY_CONDITIONS_VARIABLE=>BOUNDARY_CONDITIONS% & 
                          & BOUNDARY_CONDITIONS_VARIABLE_TYPE_MAP(FIELD_U_VARIABLE_TYPE)%PTR
                        IF(ASSOCIATED(BOUNDARY_CONDITIONS_VARIABLE)) THEN

                          CALL FIELD_NUMBER_OF_COMPONENTS_GET(EQUATIONS_SET%GEOMETRY%GEOMETRIC_FIELD,FIELD_U_VARIABLE_TYPE, &
                            & NUMBER_OF_DIMENSIONS,ERR,ERROR,*999)
                          CALL FIELD_PARAMETER_SET_DATA_GET(EQUATIONS_SET%INDEPENDENT%INDEPENDENT_FIELD,FIELD_U_VARIABLE_TYPE, & 
                            & FIELD_MESH_VELOCITY_SET_TYPE,MESH_VELOCITY_VALUES,ERR,ERROR,*999)
                          CALL FIELD_PARAMETER_SET_DATA_GET(EQUATIONS_SET%INDEPENDENT%INDEPENDENT_FIELD,FIELD_U_VARIABLE_TYPE, & 
                            & FIELD_BOUNDARY_SET_TYPE,BOUNDARY_VALUES,ERR,ERROR,*999)
    
                          CALL FLUID_MECHANICS_IO_READ_BOUNDARY_CONDITIONS(SOLVER_DYNAMIC_TYPE,BOUNDARY_VALUES, & 
                            & NUMBER_OF_DIMENSIONS,BOUNDARY_CONDITION_FIXED_INLET,CURRENT_TIME)

                          DO equations_row_number=1,EQUATIONS%EQUATIONS_MAPPING%TOTAL_NUMBER_OF_ROWS
                            DISPLACEMENT_VALUE=0.0_DP
                            BOUNDARY_CONDITION_CHECK_VARIABLE=BOUNDARY_CONDITIONS_VARIABLE% & 
                              & GLOBAL_BOUNDARY_CONDITIONS(equations_row_number)
                            IF(BOUNDARY_CONDITION_CHECK_VARIABLE==BOUNDARY_CONDITION_MOVED_WALL) THEN
                              CALL FIELD_PARAMETER_SET_UPDATE_LOCAL_DOF(EQUATIONS_SET%DEPENDENT%DEPENDENT_FIELD, & 
                                & FIELD_U_VARIABLE_TYPE,FIELD_VALUES_SET_TYPE,equations_row_number, & 
                                & MESH_VELOCITY_VALUES(equations_row_number),ERR,ERROR,*999)
                            ELSE IF(BOUNDARY_CONDITION_CHECK_VARIABLE==BOUNDARY_CONDITION_FIXED_INLET) THEN
                              CALL FIELD_PARAMETER_SET_UPDATE_LOCAL_DOF(EQUATIONS_SET%DEPENDENT%DEPENDENT_FIELD, & 
                                & FIELD_U_VARIABLE_TYPE,FIELD_VALUES_SET_TYPE,equations_row_number, & 
                                & BOUNDARY_VALUES(equations_row_number),ERR,ERROR,*999)
                            END IF
                          END DO
                        ELSE
                          CALL FLAG_ERROR("Boundary condition variable is not associated.",ERR,ERROR,*999)
                        END IF
                      ELSE
                        CALL FLAG_ERROR("Boundary conditions are not associated.",ERR,ERROR,*999)
                      END IF
                    ELSE
                      CALL FLAG_ERROR("Equations set is not associated.",ERR,ERROR,*999)
                    END IF
                  ELSE
                    CALL FLAG_ERROR("Equations are not associated.",ERR,ERROR,*999)
                  END IF                
                ELSE
                  CALL FLAG_ERROR("Solver equations are not associated.",ERR,ERROR,*999)
                END IF  
                CALL FIELD_PARAMETER_SET_UPDATE_START(EQUATIONS_SET%DEPENDENT%DEPENDENT_FIELD,FIELD_U_VARIABLE_TYPE, & 
                  & FIELD_VALUES_SET_TYPE,ERR,ERROR,*999)
                CALL FIELD_PARAMETER_SET_UPDATE_FINISH(EQUATIONS_SET%DEPENDENT%DEPENDENT_FIELD,FIELD_U_VARIABLE_TYPE, & 
                  & FIELD_VALUES_SET_TYPE,ERR,ERROR,*999)
              END IF
              ! do nothing ???
            CASE DEFAULT
              LOCAL_ERROR="Problem subtype "//TRIM(NUMBER_TO_VSTRING(CONTROL_LOOP%PROBLEM%SUBTYPE,"*",ERR,ERROR))// &
                & " is not valid for a Navier-Stokes equation fluid type of a fluid mechanics problem class."
            CALL FLAG_ERROR(LOCAL_ERROR,ERR,ERROR,*999)
          END SELECT
        ELSE
          CALL FLAG_ERROR("Problem is not associated.",ERR,ERROR,*999)
        ENDIF
      ELSE
        CALL FLAG_ERROR("Solver is not associated.",ERR,ERROR,*999)
      ENDIF
    ELSE
      CALL FLAG_ERROR("Control loop is not associated.",ERR,ERROR,*999)
    ENDIF

    CALL EXITS("NAVIER_STOKES_PRE_SOLVE_UPDATE_BOUNDARY_CONDITIONS")
    RETURN
999 CALL ERRORS("NAVIER_STOKES_PRE_SOLVE_UPDATE_BOUNDARY_CONDITIONS",ERR,ERROR)
    CALL EXITS("NAVIER_STOKES_PRE_SOLVE_UPDATE_BOUNDARY_CONDITIONS")
    RETURN 1
  END SUBROUTINE NAVIER_STOKES_PRE_SOLVE_UPDATE_BOUNDARY_CONDITIONS

  !
  !================================================================================================================================
  !
  !>Update mesh velocity and move mesh for ALE Navier-Stokes problem
  SUBROUTINE NAVIER_STOKES_PRE_SOLVE_ALE_UPDATE_MESH(CONTROL_LOOP,SOLVER,ERR,ERROR,*)

    !Argument variables
    TYPE(CONTROL_LOOP_TYPE), POINTER :: CONTROL_LOOP !<A pointer to the control loop to solve.
    TYPE(SOLVER_TYPE), POINTER :: SOLVER !<A pointer to the solvers
    INTEGER(INTG), INTENT(OUT) :: ERR !<The error code
    TYPE(VARYING_STRING), INTENT(OUT) :: ERROR !<The error string
    !Local Variables
    TYPE(SOLVER_TYPE), POINTER :: SOLVER_ALE_NAVIER_STOKES, SOLVER_LAPLACE !<A pointer to the solvers
    TYPE(FIELD_TYPE), POINTER :: DEPENDENT_FIELD_LAPLACE, INDEPENDENT_FIELD_ALE_NAVIER_STOKES
    TYPE(SOLVER_EQUATIONS_TYPE), POINTER :: SOLVER_EQUATIONS_LAPLACE, SOLVER_EQUATIONS_ALE_NAVIER_STOKES  !<A pointer to the solver equations
    TYPE(SOLVER_MAPPING_TYPE), POINTER :: SOLVER_MAPPING_LAPLACE, SOLVER_MAPPING_ALE_NAVIER_STOKES !<A pointer to the solver mapping
    TYPE(EQUATIONS_SET_TYPE), POINTER :: EQUATIONS_SET_LAPLACE, EQUATIONS_SET_ALE_NAVIER_STOKES !<A pointer to the equations set
    TYPE(EQUATIONS_TYPE), POINTER :: EQUATIONS
    TYPE(EQUATIONS_MAPPING_TYPE), POINTER :: EQUATIONS_MAPPING
    TYPE(VARYING_STRING) :: LOCAL_ERROR

    REAL(DP) :: CURRENT_TIME,TIME_INCREMENT,ALPHA
    REAL(DP), POINTER :: MESH_DISPLACEMENT_VALUES(:)
    INTEGER(INTG) :: I,NUMBER_OF_DIMENSIONS_LAPLACE
    INTEGER(INTG) :: NUMBER_OF_DIMENSIONS_ALE_NAVIER_STOKES,GEOMETRIC_MESH_COMPONENT,equations_row_number


    CALL ENTERS("NAVIER_STOKES_PRE_SOLVE_ALE_UPDATE_MESH",ERR,ERROR,*999)

    IF(ASSOCIATED(CONTROL_LOOP)) THEN
      CALL CONTROL_LOOP_CURRENT_TIMES_GET(CONTROL_LOOP,CURRENT_TIME,TIME_INCREMENT,ERR,ERROR,*999)
!       write(*,*)'CURRENT_TIME = ',CURRENT_TIME
!       write(*,*)'TIME_INCREMENT = ',TIME_INCREMENT

      NULLIFY(SOLVER_LAPLACE)
      NULLIFY(SOLVER_ALE_NAVIER_STOKES)

      IF(ASSOCIATED(SOLVER)) THEN
        IF(ASSOCIATED(CONTROL_LOOP%PROBLEM)) THEN
          SELECT CASE(CONTROL_LOOP%PROBLEM%SUBTYPE)
            CASE(PROBLEM_STATIC_NAVIER_STOKES_SUBTYPE,PROBLEM_LAPLACE_NAVIER_STOKES_SUBTYPE)
              ! do nothing ???
            CASE(PROBLEM_TRANSIENT_NAVIER_STOKES_SUBTYPE)
              ! do nothing ???
            CASE(PROBLEM_ALE_NAVIER_STOKES_SUBTYPE)
              !Update mesh within the dynamic solver
              IF(SOLVER%SOLVE_TYPE==SOLVER_DYNAMIC_TYPE) THEN
                IF(SOLVER%DYNAMIC_SOLVER%ALE) THEN

                  !Get the dependent field for the three component Laplace problem
                  CALL SOLVERS_SOLVER_GET(SOLVER%SOLVERS,1,SOLVER_LAPLACE,ERR,ERROR,*999)
                  SOLVER_EQUATIONS_LAPLACE=>SOLVER_LAPLACE%SOLVER_EQUATIONS
                  IF(ASSOCIATED(SOLVER_EQUATIONS_LAPLACE)) THEN
                    SOLVER_MAPPING_LAPLACE=>SOLVER_EQUATIONS_LAPLACE%SOLVER_MAPPING
                    IF(ASSOCIATED(SOLVER_MAPPING_LAPLACE)) THEN
                      EQUATIONS_SET_LAPLACE=>SOLVER_MAPPING_LAPLACE%EQUATIONS_SETS(1)%PTR
                      IF(ASSOCIATED(EQUATIONS_SET_LAPLACE)) THEN
                        DEPENDENT_FIELD_LAPLACE=>EQUATIONS_SET_LAPLACE%DEPENDENT%DEPENDENT_FIELD
                      ELSE
                        CALL FLAG_ERROR("Laplace equations set is not associated.",ERR,ERROR,*999)
                      END IF

                      CALL FIELD_NUMBER_OF_COMPONENTS_GET(EQUATIONS_SET_LAPLACE%GEOMETRY%GEOMETRIC_FIELD,FIELD_U_VARIABLE_TYPE, &
                        & NUMBER_OF_DIMENSIONS_LAPLACE,ERR,ERROR,*999)

                    ELSE
                      CALL FLAG_ERROR("Laplace solver mapping is not associated.",ERR,ERROR,*999)
                    END IF
                  ELSE
                    CALL FLAG_ERROR("Laplace solver equations are not associated.",ERR,ERROR,*999)
                  END IF

                  !Get the independent field for the ALE Navier-Stokes problem
                  CALL SOLVERS_SOLVER_GET(SOLVER%SOLVERS,2,SOLVER_ALE_NAVIER_STOKES,ERR,ERROR,*999)
                  SOLVER_EQUATIONS_ALE_NAVIER_STOKES=>SOLVER_ALE_NAVIER_STOKES%SOLVER_EQUATIONS
                  IF(ASSOCIATED(SOLVER_EQUATIONS_ALE_NAVIER_STOKES)) THEN
                    SOLVER_MAPPING_ALE_NAVIER_STOKES=>SOLVER_EQUATIONS_ALE_NAVIER_STOKES%SOLVER_MAPPING
                    IF(ASSOCIATED(SOLVER_MAPPING_ALE_NAVIER_STOKES)) THEN
                      EQUATIONS_SET_ALE_NAVIER_STOKES=>SOLVER_MAPPING_ALE_NAVIER_STOKES%EQUATIONS_SETS(1)%PTR
                      IF(ASSOCIATED(EQUATIONS_SET_ALE_NAVIER_STOKES)) THEN
                        INDEPENDENT_FIELD_ALE_NAVIER_STOKES=>EQUATIONS_SET_ALE_NAVIER_STOKES%INDEPENDENT%INDEPENDENT_FIELD
                      ELSE
                        CALL FLAG_ERROR("ALE Navier-Stokes equations set is not associated.",ERR,ERROR,*999)
                      END IF

                      CALL FIELD_NUMBER_OF_COMPONENTS_GET(EQUATIONS_SET_ALE_NAVIER_STOKES%GEOMETRY%GEOMETRIC_FIELD, & 
                        & FIELD_U_VARIABLE_TYPE,NUMBER_OF_DIMENSIONS_ALE_NAVIER_STOKES,ERR,ERROR,*999)

                    ELSE
                      CALL FLAG_ERROR("ALE Navier-Stokes solver mapping is not associated.",ERR,ERROR,*999)
                    END IF
                  ELSE
                    CALL FLAG_ERROR("ALE Navier-Stokes solver equations are not associated.",ERR,ERROR,*999)
                  END IF
 
                  !Copy result from Laplace mesh movement to Navier-Stokes' independent field
                  IF(NUMBER_OF_DIMENSIONS_ALE_NAVIER_STOKES==NUMBER_OF_DIMENSIONS_LAPLACE) THEN
                    DO I=1,NUMBER_OF_DIMENSIONS_ALE_NAVIER_STOKES
                      CALL FIELD_PARAMETERS_TO_FIELD_PARAMETERS_COMPONENT_COPY(DEPENDENT_FIELD_LAPLACE, & 
                        & FIELD_U_VARIABLE_TYPE,FIELD_VALUES_SET_TYPE,I,INDEPENDENT_FIELD_ALE_NAVIER_STOKES, & 
                        & FIELD_U_VARIABLE_TYPE,FIELD_MESH_DISPLACEMENT_SET_TYPE,I,ERR,ERROR,*999)
                    END DO
                  ELSE
                    CALL FLAG_ERROR("Dimension of Laplace and ALE Navier-Stokes equations set is not consistent.",ERR,ERROR,*999)
                  END IF

                  !Use calculated values to update mesh
                  CALL FIELD_COMPONENT_MESH_COMPONENT_GET(EQUATIONS_SET_ALE_NAVIER_STOKES%GEOMETRY%GEOMETRIC_FIELD, & 
                    & FIELD_U_VARIABLE_TYPE,1,GEOMETRIC_MESH_COMPONENT,ERR,ERROR,*999)
                  CALL FIELD_PARAMETER_SET_DATA_GET(INDEPENDENT_FIELD_ALE_NAVIER_STOKES,FIELD_U_VARIABLE_TYPE, & 
                    & FIELD_MESH_DISPLACEMENT_SET_TYPE,MESH_DISPLACEMENT_VALUES,ERR,ERROR,*999)
                  EQUATIONS=>SOLVER_MAPPING_LAPLACE%EQUATIONS_SET_TO_SOLVER_MAP(1)%EQUATIONS
                  IF(ASSOCIATED(EQUATIONS)) THEN
                    EQUATIONS_MAPPING=>EQUATIONS%EQUATIONS_MAPPING
                    IF(ASSOCIATED(EQUATIONS_MAPPING)) THEN
                      DO equations_row_number=1,EQUATIONS%EQUATIONS_MAPPING%TOTAL_NUMBER_OF_ROWS
                        CALL FIELD_PARAMETER_SET_ADD_LOCAL_DOF(EQUATIONS_SET_ALE_NAVIER_STOKES%GEOMETRY%GEOMETRIC_FIELD, & 
                          & FIELD_U_VARIABLE_TYPE,FIELD_VALUES_SET_TYPE,equations_row_number, & 
                          & MESH_DISPLACEMENT_VALUES(equations_row_number),ERR,ERROR,*999)
                      END DO
                    ELSE
                      CALL FLAG_ERROR("Equations mapping is not associated.",ERR,ERROR,*999)
                    END IF
                  ELSE
                    CALL FLAG_ERROR("Equations are not associated.",ERR,ERROR,*999)
                  END IF
                  CALL FIELD_PARAMETER_SET_UPDATE_START(EQUATIONS_SET_ALE_NAVIER_STOKES%GEOMETRY%GEOMETRIC_FIELD, & 
                    & FIELD_U_VARIABLE_TYPE,FIELD_VALUES_SET_TYPE,ERR,ERROR,*999)
                  CALL FIELD_PARAMETER_SET_UPDATE_FINISH(EQUATIONS_SET_ALE_NAVIER_STOKES%GEOMETRY%GEOMETRIC_FIELD, & 
                    & FIELD_U_VARIABLE_TYPE,FIELD_VALUES_SET_TYPE,ERR,ERROR,*999)

                  !Now use displacement values to calculate velocity values
                  TIME_INCREMENT=CONTROL_LOOP%TIME_LOOP%TIME_INCREMENT
                  ALPHA=1.0_DP/TIME_INCREMENT
                  CALL FIELD_PARAMETER_SETS_COPY(INDEPENDENT_FIELD_ALE_NAVIER_STOKES,FIELD_U_VARIABLE_TYPE, & 
                    & FIELD_MESH_DISPLACEMENT_SET_TYPE,FIELD_MESH_VELOCITY_SET_TYPE,ALPHA,ERR,ERROR,*999)
                ELSE  
                  CALL FLAG_ERROR("Mesh motion calculation not successful for ALE problem.",ERR,ERROR,*999)
                END IF
              ELSE  
                CALL FLAG_ERROR("Mesh update is not defined for non-dynamic problems.",ERR,ERROR,*999)
              END IF
            CASE DEFAULT
              LOCAL_ERROR="Problem subtype "//TRIM(NUMBER_TO_VSTRING(CONTROL_LOOP%PROBLEM%SUBTYPE,"*",ERR,ERROR))// &
                & " is not valid for a Navier-Stokes equation fluid type of a fluid mechanics problem class."
            CALL FLAG_ERROR(LOCAL_ERROR,ERR,ERROR,*999)
          END SELECT
        ELSE
          CALL FLAG_ERROR("Problem is not associated.",ERR,ERROR,*999)
        ENDIF
      ELSE
        CALL FLAG_ERROR("Solver is not associated.",ERR,ERROR,*999)
      ENDIF
    ELSE
      CALL FLAG_ERROR("Control loop is not associated.",ERR,ERROR,*999)
    ENDIF
    CALL EXITS("NAVIER_STOKES_PRE_SOLVE_ALE_UPDATE_MESH")
    RETURN
999 CALL ERRORS("NAVIER_STOKES_PRE_SOLVE_ALE_UPDATE_MESH",ERR,ERROR)
    CALL EXITS("NAVIER_STOKES_PRE_SOLVE_ALE_UPDATE_MESH")
    RETURN 1
  END SUBROUTINE NAVIER_STOKES_PRE_SOLVE_ALE_UPDATE_MESH

  !
  !================================================================================================================================
  !
  !>Update mesh parameters for three component Laplace problem
  SUBROUTINE NAVIER_STOKES_PRE_SOLVE_ALE_UPDATE_PARAMETERS(CONTROL_LOOP,SOLVER,ERR,ERROR,*)

    !Argument variables
    TYPE(CONTROL_LOOP_TYPE), POINTER :: CONTROL_LOOP !<A pointer to the control loop to solve.
    TYPE(SOLVER_TYPE), POINTER :: SOLVER !<A pointer to the solver
    INTEGER(INTG), INTENT(OUT) :: ERR !<The error code
    TYPE(VARYING_STRING), INTENT(OUT) :: ERROR !<The error string
    !Local Variables
    TYPE(FIELD_TYPE), POINTER :: INDEPENDENT_FIELD
    TYPE(SOLVER_EQUATIONS_TYPE), POINTER :: SOLVER_EQUATIONS  !<A pointer to the solver equations
    TYPE(SOLVER_MAPPING_TYPE), POINTER :: SOLVER_MAPPING !<A pointer to the solver mapping
    TYPE(EQUATIONS_SET_TYPE), POINTER :: EQUATIONS_SET !<A pointer to the equations set
    TYPE(EQUATIONS_TYPE), POINTER :: EQUATIONS
    TYPE(VARYING_STRING) :: LOCAL_ERROR

    REAL(DP) :: CURRENT_TIME,TIME_INCREMENT
    INTEGER(INTG) :: equations_row_number
    REAL(DP), POINTER :: MESH_STIFF_VALUES(:)


    CALL ENTERS("NAVIER_STOKES_PRE_SOLVE_ALE_UPDATE_PARAMETERS",ERR,ERROR,*999)

    IF(ASSOCIATED(CONTROL_LOOP)) THEN
      CALL CONTROL_LOOP_CURRENT_TIMES_GET(CONTROL_LOOP,CURRENT_TIME,TIME_INCREMENT,ERR,ERROR,*999)
!       write(*,*)'CURRENT_TIME = ',CURRENT_TIME
!       write(*,*)'TIME_INCREMENT = ',TIME_INCREMENT
      IF(ASSOCIATED(SOLVER)) THEN
        IF(ASSOCIATED(CONTROL_LOOP%PROBLEM)) THEN
          SELECT CASE(CONTROL_LOOP%PROBLEM%SUBTYPE)
            CASE(PROBLEM_STATIC_NAVIER_STOKES_SUBTYPE,PROBLEM_LAPLACE_NAVIER_STOKES_SUBTYPE)
              ! do nothing ???
            CASE(PROBLEM_TRANSIENT_NAVIER_STOKES_SUBTYPE)
              ! do nothing ???
            CASE(PROBLEM_ALE_NAVIER_STOKES_SUBTYPE)
              IF(SOLVER%SOLVE_TYPE==SOLVER_LINEAR_TYPE) THEN
                !Get the independent field for the ALE Navier-Stokes problem
                SOLVER_EQUATIONS=>SOLVER%SOLVER_EQUATIONS
                IF(ASSOCIATED(SOLVER_EQUATIONS)) THEN
                  SOLVER_MAPPING=>SOLVER_EQUATIONS%SOLVER_MAPPING
                  IF(ASSOCIATED(SOLVER_MAPPING)) THEN
                    EQUATIONS_SET=>SOLVER_MAPPING%EQUATIONS_SETS(1)%PTR
                    CALL FIELD_PARAMETER_SET_DATA_GET(EQUATIONS_SET%INDEPENDENT%INDEPENDENT_FIELD,FIELD_U_VARIABLE_TYPE, & 
                      & FIELD_VALUES_SET_TYPE,MESH_STIFF_VALUES,ERR,ERROR,*999)
                    IF(ASSOCIATED(EQUATIONS_SET)) THEN
                      EQUATIONS=>SOLVER_MAPPING%EQUATIONS_SET_TO_SOLVER_MAP(1)%EQUATIONS
                      IF(ASSOCIATED(EQUATIONS)) THEN
                        INDEPENDENT_FIELD=>EQUATIONS_SET%INDEPENDENT%INDEPENDENT_FIELD
                        IF(ASSOCIATED(INDEPENDENT_FIELD)) THEN
                          DO equations_row_number=1,EQUATIONS%EQUATIONS_MAPPING%TOTAL_NUMBER_OF_ROWS
                            !Calculation of K values dependent on current mesh topology
                            MESH_STIFF_VALUES(equations_row_number)=1.0_DP

                            CALL FIELD_PARAMETER_SET_UPDATE_LOCAL_DOF(EQUATIONS_SET%INDEPENDENT%INDEPENDENT_FIELD, & 
                              & FIELD_U_VARIABLE_TYPE,FIELD_VALUES_SET_TYPE,equations_row_number, & 
                              & MESH_STIFF_VALUES(equations_row_number),ERR,ERROR,*999)
                          END DO
                        ELSE
                          CALL FLAG_ERROR("Independent field is not associated.",ERR,ERROR,*999)
                        END IF
                      ELSE
                        CALL FLAG_ERROR("Equations are not associated.",ERR,ERROR,*999)
                      END IF
                    ELSE
                      CALL FLAG_ERROR("Equations set is not associated.",ERR,ERROR,*999)
                    END IF
                  ELSE
                    CALL FLAG_ERROR("Solver mapping is not associated.",ERR,ERROR,*999)
                  END IF
                ELSE
                  CALL FLAG_ERROR("Solver equations are not associated.",ERR,ERROR,*999)
                END IF
              ELSE IF(SOLVER%SOLVE_TYPE==SOLVER_DYNAMIC_TYPE) THEN
                CALL FLAG_ERROR("Mesh motion calculation not successful for ALE problem.",ERR,ERROR,*999)
              END IF
            CASE DEFAULT
              LOCAL_ERROR="Problem subtype "//TRIM(NUMBER_TO_VSTRING(CONTROL_LOOP%PROBLEM%SUBTYPE,"*",ERR,ERROR))// &
                & " is not valid for a Navier-Stokes equation fluid type of a fluid mechanics problem class."
            CALL FLAG_ERROR(LOCAL_ERROR,ERR,ERROR,*999)
          END SELECT
        ELSE
          CALL FLAG_ERROR("Problem is not associated.",ERR,ERROR,*999)
        ENDIF
      ELSE
        CALL FLAG_ERROR("Solver is not associated.",ERR,ERROR,*999)
      ENDIF
    ELSE
      CALL FLAG_ERROR("Control loop is not associated.",ERR,ERROR,*999)
    ENDIF
    CALL EXITS("NAVIER_STOKES_PRE_SOLVE_ALE_UPDATE_PARAMETERS")
    RETURN
999 CALL ERRORS("NAVIER_STOKES_PRE_SOLVE_ALE_UPDATE_PARAMETERS",ERR,ERROR)
    CALL EXITS("NAVIER_STOKES_PRE_SOLVE_ALE_UPDATE_PARAMETERS")
    RETURN 1
  END SUBROUTINE NAVIER_STOKES_PRE_SOLVE_ALE_UPDATE_PARAMETERS


  !
  !================================================================================================================================
  !

  !>Output data post solve
  SUBROUTINE NAVIER_STOKES_POST_SOLVE_OUTPUT_DATA(CONTROL_LOOP,SOLVER,ERR,ERROR,*)

    !Argument variables
    TYPE(CONTROL_LOOP_TYPE), POINTER :: CONTROL_LOOP !<A pointer to the control loop to solve.
    TYPE(SOLVER_TYPE), POINTER :: SOLVER !<A pointer to the solver
    INTEGER(INTG), INTENT(OUT) :: ERR !<The error code
    TYPE(VARYING_STRING), INTENT(OUT) :: ERROR !<The error string
    !Local Variables
    TYPE(SOLVER_EQUATIONS_TYPE), POINTER :: SOLVER_EQUATIONS  !<A pointer to the solver equations
    TYPE(SOLVER_MAPPING_TYPE), POINTER :: SOLVER_MAPPING !<A pointer to the solver mapping
    TYPE(EQUATIONS_SET_TYPE), POINTER :: EQUATIONS_SET !<A pointer to the equations set
    TYPE(VARYING_STRING) :: LOCAL_ERROR

    REAL(DP) :: CURRENT_TIME,TIME_INCREMENT
    INTEGER(INTG) :: EQUATIONS_SET_IDX,CURRENT_LOOP_ITERATION,OUTPUT_ITERATION_NUMBER

    LOGICAL :: EXPORT_FIELD
    TYPE(VARYING_STRING) :: FILE,METHOD
    CHARACTER(14) :: OUTPUT_FILE


    CALL ENTERS("NAVIER_STOKES_POST_SOLVE_OUTPUT_DATA",ERR,ERROR,*999)

    IF(ASSOCIATED(CONTROL_LOOP)) THEN
      CALL CONTROL_LOOP_CURRENT_TIMES_GET(CONTROL_LOOP,CURRENT_TIME,TIME_INCREMENT,ERR,ERROR,*999)
!       write(*,*)'CURRENT_TIME = ',CURRENT_TIME
!       write(*,*)'TIME_INCREMENT = ',TIME_INCREMENT
      IF(ASSOCIATED(SOLVER)) THEN
        IF(ASSOCIATED(CONTROL_LOOP%PROBLEM)) THEN
          SELECT CASE(CONTROL_LOOP%PROBLEM%SUBTYPE)
            CASE(PROBLEM_STATIC_NAVIER_STOKES_SUBTYPE,PROBLEM_LAPLACE_NAVIER_STOKES_SUBTYPE, & 
              & PROBLEM_TRANSIENT_NAVIER_STOKES_SUBTYPE,PROBLEM_ALE_NAVIER_STOKES_SUBTYPE)
              SOLVER_EQUATIONS=>SOLVER%SOLVER_EQUATIONS
              IF(ASSOCIATED(SOLVER_EQUATIONS)) THEN
                SOLVER_MAPPING=>SOLVER_EQUATIONS%SOLVER_MAPPING
                IF(ASSOCIATED(SOLVER_MAPPING)) THEN
                  !Make sure the equations sets are up to date
                  DO equations_set_idx=1,SOLVER_MAPPING%NUMBER_OF_EQUATIONS_SETS
                    EQUATIONS_SET=>SOLVER_MAPPING%EQUATIONS_SETS(equations_set_idx)%PTR

                    CURRENT_LOOP_ITERATION=CONTROL_LOOP%TIME_LOOP%ITERATION_NUMBER
                    OUTPUT_ITERATION_NUMBER=CONTROL_LOOP%TIME_LOOP%OUTPUT_NUMBER

                    IF(OUTPUT_ITERATION_NUMBER/=0) THEN
                      IF(CONTROL_LOOP%TIME_LOOP%CURRENT_TIME<=CONTROL_LOOP%TIME_LOOP%STOP_TIME) THEN
                        IF(CURRENT_LOOP_ITERATION<10) THEN
                          WRITE(OUTPUT_FILE,'("TIME_STEP_000",I0)') CURRENT_LOOP_ITERATION
                        ELSE IF(CURRENT_LOOP_ITERATION<100) THEN
                          WRITE(OUTPUT_FILE,'("TIME_STEP_00",I0)') CURRENT_LOOP_ITERATION
                        ELSE IF(CURRENT_LOOP_ITERATION<1000) THEN
                          WRITE(OUTPUT_FILE,'("TIME_STEP_0",I0)') CURRENT_LOOP_ITERATION
                        ELSE IF(CURRENT_LOOP_ITERATION<10000) THEN
                          WRITE(OUTPUT_FILE,'("TIME_STEP_",I0)') CURRENT_LOOP_ITERATION
                        END IF
                        FILE=OUTPUT_FILE
  !          FILE="TRANSIENT_OUTPUT"
                        METHOD="FORTRAN"
                        EXPORT_FIELD=.TRUE.
                        IF(EXPORT_FIELD) THEN          
                          IF(MOD(CURRENT_LOOP_ITERATION,OUTPUT_ITERATION_NUMBER)==0)  THEN   
                            CALL WRITE_STRING(GENERAL_OUTPUT_TYPE,"...",ERR,ERROR,*999)
                            CALL WRITE_STRING(GENERAL_OUTPUT_TYPE,"Now export fields... ",ERR,ERROR,*999)
                            CALL FLUID_MECHANICS_IO_WRITE_CMGUI(EQUATIONS_SET%REGION,FILE,ERR,ERROR,*999)
                            CALL WRITE_STRING(GENERAL_OUTPUT_TYPE,OUTPUT_FILE,ERR,ERROR,*999)
                            CALL WRITE_STRING(GENERAL_OUTPUT_TYPE,"...",ERR,ERROR,*999)
                          ENDIF
                        ENDIF 
                      ENDIF 
                    ENDIF
                  ENDDO
                ENDIF
              ENDIF
            CASE DEFAULT
              LOCAL_ERROR="Problem subtype "//TRIM(NUMBER_TO_VSTRING(CONTROL_LOOP%PROBLEM%SUBTYPE,"*",ERR,ERROR))// &
                & " is not valid for a Navier-Stokes equation fluid type of a fluid mechanics problem class."
            CALL FLAG_ERROR(LOCAL_ERROR,ERR,ERROR,*999)
          END SELECT
        ELSE
          CALL FLAG_ERROR("Problem is not associated.",ERR,ERROR,*999)
        ENDIF
      ELSE
        CALL FLAG_ERROR("Solver is not associated.",ERR,ERROR,*999)
      ENDIF
    ELSE
      CALL FLAG_ERROR("Control loop is not associated.",ERR,ERROR,*999)
    ENDIF
    CALL EXITS("NAVIER_STOKES_POST_SOLVE_OUTPUT_DATA")
    RETURN
999 CALL ERRORS("NAVIER_STOKES_POST_SOLVE_OUTPUT_DATA",ERR,ERROR)
    CALL EXITS("NAVIER_STOKES_POST_SOLVE_OUTPUT_DATA")
    RETURN 1
  END SUBROUTINE NAVIER_STOKES_POST_SOLVE_OUTPUT_DATA

  !
  !================================================================================================================================
  !

END MODULE NAVIER_STOKES_EQUATIONS_ROUTINES
      
  !   
  !================================================================================================================================
  !   
