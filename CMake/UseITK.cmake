# This file sets up include directories, link directories, and
# compiler settings for a project to use ITK.  It should not be
# included directly, but rather through the ITK_USE_FILE setting
# obtained from ITKConfig.cmake.

# Add compiler flags needed to use ITK.
set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} ${ITK_REQUIRED_C_FLAGS}")
set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} ${ITK_REQUIRED_CXX_FLAGS}")
set(CMAKE_EXE_LINKER_FLAGS "${CMAKE_EXE_LINKER_FLAGS} ${ITK_REQUIRED_LINK_FLAGS}")
set(CMAKE_SHARED_LINKER_FLAGS "${CMAKE_SHARED_LINKER_FLAGS} ${ITK_REQUIRED_LINK_FLAGS}")
set(CMAKE_MODULE_LINKER_FLAGS "${CMAKE_MODULE_LINKER_FLAGS} ${ITK_REQUIRED_LINK_FLAGS}")

# Add FFTW include and library directories
if (ITK_USE_FFTWF OR ITK_USE_FFTWD)
  set(ITK_INCLUDE_DIRS ${ITK_INCLUDE_DIRS} "${ITK_FFTW_INCLUDE_PATH}")
  set(ITK_LIBRARY_DIRS ${ITK_LIBRARY_DIRS} "${ITK_FFTW_LIBDIR}")
endif()

# Add include directories needed to use ITK.
include_directories(BEFORE ${ITK_INCLUDE_DIRS})

# Add link directories needed to use ITK.
link_directories(${ITK_LIBRARY_DIRS})

if(NOT ITK_NO_IO_FACTORY_REGISTER_MANAGER)
  #
  # Infrastructure for registering automatically the factories of commonly used IO formats
  #

  #for Image IO
  set(LIST_OF_FACTORIES_REGISTRATION "")
  set(LIST_OF_FACTORY_NAMES "")

  foreach (ImageFormat  JPEG GDCM BMP LSM PNG TIFF VTK Stimulate BioRad Meta)
    if (ITKIO${ImageFormat}_LOADED)
      set (LIST_OF_FACTORIES_REGISTRATION "${LIST_OF_FACTORIES_REGISTRATION}void ${ImageFormat}ImageIOFactoryRegister__Private(void);")
      set (LIST_OF_FACTORY_NAMES  "${LIST_OF_FACTORY_NAMES}${ImageFormat}ImageIOFactoryRegister__Private,")
    endif()
  endforeach()

  foreach (ImageFormat  Nifti Nrrd Gipl HDF5 )
    string(TOUPPER ${ImageFormat} ImageFormat_UPPER)
    if (ITKIO${ImageFormat_UPPER}_LOADED)
      set (LIST_OF_FACTORIES_REGISTRATION "${LIST_OF_FACTORIES_REGISTRATION}void ${ImageFormat}ImageIOFactoryRegister__Private(void);")
      set (LIST_OF_FACTORY_NAMES  "${LIST_OF_FACTORY_NAMES}${ImageFormat}ImageIOFactoryRegister__Private,")
    endif()
  endforeach()

  # add ImageIOs in review to the automatic registration
  if (ITK_USE_REVIEW)
    foreach (ImageFormat MRC)
      set (LIST_OF_FACTORIES_REGISTRATION "${LIST_OF_FACTORIES_REGISTRATION}void ${ImageFormat}ImageIOFactoryRegister__Private(void);")
      set (LIST_OF_FACTORY_NAMES  "${LIST_OF_FACTORY_NAMES}${ImageFormat}ImageIOFactoryRegister__Private,")
    endforeach()
  endif()

  get_filename_component(_selfdir "${CMAKE_CURRENT_LIST_FILE}" PATH)
  configure_file(${_selfdir}/itkImageIOFactoryRegisterManager.h.in
   "${CMAKE_CURRENT_BINARY_DIR}/ITKIOFactoryRegistration/itkImageIOFactoryRegisterManager.h" @ONLY)
  unset(LIST_OF_FACTORIES_REGISTRATION)
  unset(LIST_OF_FACTORY_NAMES)

  # for Transform IO
  set(LIST_OF_FACTORIES_REGISTRATION "")
  set(LIST_OF_FACTORY_NAMES "")

  foreach (TransformFormat  Matlab Txt HDF5)
      set (LIST_OF_FACTORIES_REGISTRATION "${LIST_OF_FACTORIES_REGISTRATION}void ${TransformFormat}TransformIOFactoryRegister__Private(void);")
      set (LIST_OF_FACTORY_NAMES  "${LIST_OF_FACTORY_NAMES}${TransformFormat}TransformIOFactoryRegister__Private,")
  endforeach()

  get_filename_component(_selfdir "${CMAKE_CURRENT_LIST_FILE}" PATH)
  configure_file(${_selfdir}/itkTransformIOFactoryRegisterManager.h.in
   "${CMAKE_CURRENT_BINARY_DIR}/ITKIOFactoryRegistration/itkTransformIOFactoryRegisterManager.h" @ONLY)
  unset(LIST_OF_FACTORIES_REGISTRATION)
  unset(LIST_OF_FACTORY_NAMES)

  #-------------------
  set_property(DIRECTORY APPEND PROPERTY COMPILE_DEFINITIONS ITK_IO_FACTORY_REGISTER_MANAGER)
  include_directories(BEFORE ${CMAKE_CURRENT_BINARY_DIR}/ITKIOFactoryRegistration)

endif()
