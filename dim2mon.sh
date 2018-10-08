package: dim2mon
version: "%(tag_basename)s"
tag: v0.0.1
requires:
  - dim
  - boost
  - Monitoring
  - "GCC-Toolchain:(?!osx)"
build_requires:
  - CMake
source: https://github.com/awegrzyn/dim2mon.git
---
#!/bin/bash -ex

cmake $SOURCEDIR                                              \
      -DCMAKE_INSTALL_PREFIX=$INSTALLROOT                     \
      -DCMAKE_EXPORT_COMPILE_COMMANDS=ON 		      \
      ${BOOST_VERSION:+-DBOOST_ROOT=$BOOST_ROOT}

cp ${BUILDDIR}/compile_commands.json ${INSTALLROOT}
make ${JOBS+-j $JOBS} install

#ModuleFile
mkdir -p etc/modulefiles
cat > etc/modulefiles/$PKGNAME <<EoF
#%Module1.0
proc ModulesHelp { } {
  global version
  puts stderr "ALICE Modulefile for $PKGNAME $PKGVERSION-@@PKGREVISION@$PKGHASH@@"
}
set version $PKGVERSION-@@PKGREVISION@$PKGHASH@@
module-whatis "ALICE Modulefile for $PKGNAME $PKGVERSION-@@PKGREVISION@$PKGHASH@@"
# Dependencies
module load BASE/1.0 ${GCC_TOOLCHAIN_VERSION:+GCC-Toolchain/$GCC_TOOLCHAIN_VERSION-$GCC_TOOLCHAIN_REVISION} dim/$DIM_VERSION-$DIM_REVISION Monitoring/$MONITORING_VERSION-$MONITORING_REVISION ${BOOST_VERSION:+boost/$BOOST_VERSION-$BOOST_REVISION}

# Our environment
setenv DIM2MON_ROOT \$::env(BASEDIR)/$PKGNAME/\$version
prepend-path PATH \$::env(DIM2MON_ROOT)/bin
prepend-path LD_LIBRARY_PATH \$::env(DIM2MON_ROOT)/lib
$([[ ${ARCHITECTURE:0:3} == osx ]] && echo "prepend-path DYLD_LIBRARY_PATH \$::env(DIM2MON_ROOT)/lib")
EoF
mkdir -p $INSTALLROOT/etc/modulefiles && rsync -a --delete etc/modulefiles/ $INSTALLROOT/etc/modulefiles
