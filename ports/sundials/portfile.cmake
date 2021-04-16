vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO LLNL/sundials
    REF v5.7.0
    SHA512 e29c6f2789e62a2d9564a9297f64ba882a5a6f897aeba6dfffffdbb404569b09aa088fa11b242643717a1e88931edf0fed7c8aee28b7e48f1c4bd42be1bef1ae
    HEAD_REF master
    PATCHES "find-klu.patch"
    GITHUB_HOST https://github.com
)

string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "static" SUN_BUILD_STATIC)
string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "dynamic" SUN_BUILD_SHARED)

if ("klu" IN_LIST FEATURES)
  set(ENABLE_KLU ON)
else()
  set(CMAKE_DISABLE_FIND_PACKAGE_SUITESPARSE ON)
endif()

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS 
        -DEXAMPLES_ENABLE=OFF
        -DBUILD_STATIC_LIBS=${SUN_BUILD_STATIC}
        -DBUILD_SHARED_LIBS=${SUN_BUILD_SHARED}
        -DENABLE_KLU=${ENABLE_KLU}
)

vcpkg_install_cmake(DISABLE_PARALLEL)

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)

file(GLOB REMOVE_DLLS
    "${CURRENT_PACKAGES_DIR}/debug/lib/*.dll"
    "${CURRENT_PACKAGES_DIR}/lib/*.dll"
)

file(GLOB DEBUG_DLLS
    "${CURRENT_PACKAGES_DIR}/debug/lib/*.dll"
)

file(GLOB DLLS
    "${CURRENT_PACKAGES_DIR}/lib/*.dll"
)

if(DLLS)
    file(INSTALL ${DLLS} DESTINATION ${CURRENT_PACKAGES_DIR}/bin)
endif()

if(DEBUG_DLLS)
    file(INSTALL ${DEBUG_DLLS} DESTINATION ${CURRENT_PACKAGES_DIR}/debug/bin)
endif()

file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
file(REMOVE "${CURRENT_PACKAGES_DIR}/LICENSE")
file(REMOVE "${CURRENT_PACKAGES_DIR}/debug/LICENSE")

if(REMOVE_DLLS)
    file(REMOVE ${REMOVE_DLLS})
endif()

vcpkg_copy_pdbs()
vcpkg_fixup_cmake_targets(CONFIG_PATH lib/cmake/${PORT})
