// -*- C++ -*-

#ifndef SLOW_CONTROLLER_HH
#define SLOW_CONTROLLER_HH

#include "Uncopyable.hh"

#include <fstream>
#include <map>
#include <string>
#include <cstdint>
#include <iomanip>

class FPGAModule;

//_____________________________________________________________________________
class SlowController : Uncopyable<SlowController>
{
public:
  SlowController( void );
  ~SlowController( void );

private:
  std::string                     m_param_name;
  std::map<std::string, uint32_t> m_param_map;
  std::string                     m_out_name;
  std::ofstream                   m_out_stream;
  FPGAModule*                     m_fpga_module;
  bool                            m_verbose;

public:
  int  Get( std::string key ) const;
  int  Read( uint32_t module_id, uint32_t local_address,
             const std::string& label, uint32_t n_read=1 );
  void SetFPGAModule( FPGAModule* module );
  void SetParamFile( const std::string& name );
  void SetOutFile( const std::string& name );
  void SetVerbose( bool v=true ) { m_verbose = v; }
  int  Write( uint32_t module_id, uint32_t local_address,
              const std::string& label );
  int  Write( uint32_t module_id, uint32_t local_address,
              const std::string& label,
              uint32_t write_data, uint32_t n_read=1 );
};

#endif
