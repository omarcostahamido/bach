# determine architecture
IF( NOT ARCH )
  IF(APPLE AND NOT CMAKE_OSX_ARCHITECTURES STREQUAL "")
    LIST(LENGTH CMAKE_OSX_ARCHITECTURES NUMARCHS)
    
    IF(NOT ${NUMARCHS}  EQUAL 1)
      MESSAGE(FATAL_ERROR "GET_ARCH.cmake::building of multiple traget architectures is currently not supported" )	    		
    ELSE(NOT ${NUMARCHS} EQUAL 1)
      LIST(GET CMAKE_OSX_ARCHITECTURES 0 ARCH)
    ENDIF(NOT ${NUMARCHS}  EQUAL 1)
  ELSE(APPLE AND NOT CMAKE_OSX_ARCHITECTURES STREQUAL "")
    IF(CMAKE_SYSTEM_PROCESSOR)
      IF(CMAKE_SYSTEM_PROCESSOR STREQUAL "unknown")
        MESSAGE(FATAL_ERROR "GET_ARCH.cmake::target architecture cannot be determined" )	
      ELSE(CMAKE_SYSTEM_PROCESSOR STREQUAL "unknown")
        SET(ARCH ${CMAKE_SYSTEM_PROCESSOR})
      ENDIF(CMAKE_SYSTEM_PROCESSOR STREQUAL "unknown")
    ELSE(CMAKE_SYSTEM_PROCESSOR)
      MESSAGE(FATAL_ERROR "GET_ARCH.cmake::target architecture cannot be determined" )	
    ENDIF(CMAKE_SYSTEM_PROCESSOR)
  ENDIF(APPLE AND NOT CMAKE_OSX_ARCHITECTURES STREQUAL "")
ENDIF(NOT ARCH )
MESSAGE(STATUS "configure for architecture ${ARCH}, CMAKE PROCESSOR = ${CMAKE_SYSTEM_PROCESSOR} HOST PROCESSOR = ${CMAKE_HOST_SYSTEM_PROCESSOR}")
