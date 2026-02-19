// -*- C++ -*-

#include <iostream>
#include <string>

#include "FPGAModule.hh"
#include "RegisterMap.hh"

//_____________________________________________________________________________
int
main(int argc, char** argv)
{
  FPGAModule module("192.168.10.30");
  int version = module.ReadModule(BCT::mid, BCT::Version, BCT::kVersionLen);
  std::cout << std::hex << version << std::endl;
  return 0;
}
