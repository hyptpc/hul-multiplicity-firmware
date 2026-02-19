// -*- C++ -*-

#ifndef FPGA_MODULE_HH
#define FPGA_MODULE_HH

#include <vector>
#include <cstdint>
#include <string>

#include "Uncopyable.hh"
#include "UDPRBCP.hh"

static const uint32_t module_id_mask  = 0xF;
static const uint32_t module_id_shift = 28U; // <<

static const uint32_t address_mask    = 0xFFF;
static const uint32_t address_shift   = 16U;  // <<

static const uint32_t exdata_mask     = 0xFFFF00;
static const uint32_t exdata_shift    = 8U;  // >>

static const uint32_t data_mask       = 0xFF;

//_____________________________________________________________________________
class FPGAModule : Uncopyable<FPGAModule>
{
public:
  typedef std::vector<unsigned char> dType;
  typedef dType::const_iterator      dcItr;
  static const uint32_t UDP_PORT = 4660;

private:
  // RBCP data structure
  // RBCP_ADDR [31:0]
  // RBCP_WD   [7:0]
  //
  // Module ID     : RBCP_ADDR[31:28]
  // Local address : RBCP_ADDR[27:16]
  // Extended data : RBCP_ADDR[15:0]
  // original data : RBCP_WD[7:0]
  const char*            m_ip_addr;
  uint32_t               m_port;
  RbcpHeader_t*          m_send_header;
  UDPRBCP::RbcpDebugMode m_disp_mode;
  dType                  m_rd_data;
  uint32_t               m_rd_word;

public:
  FPGAModule(const std::string& ip_addr,
             uint32_t port=UDP_PORT,
             RbcpHeader_t* send_header=nullptr,
             UDPRBCP::RbcpDebugMode disp_mode=UDPRBCP::kDispNo);
  FPGAModule(const char* ip_addr,
             uint32_t port=UDP_PORT,
             RbcpHeader_t* send_header=nullptr,
             UDPRBCP::RbcpDebugMode disp_mode=UDPRBCP::kDispNo);
  virtual ~FPGAModule(void);

  // 1 byte write rbcp
  int WriteModule(uint32_t module_id,
                  uint32_t local_address,
                  uint32_t write_data);

  // n cycle read rbcp by inlrementing laddr
  // (data are storeod in m_rd_word)
  uint32_t ReadModule(uint32_t module_id,
                      uint32_t local_address,
                      int n_cycle);

  // n byte read rbcp
  // (data are stored in m_rd_data)
  int ReadModule_nByte(uint32_t module_id,
                       uint32_t local_address,
                       uint32_t nbyte);

  uint32_t GetReadWord(void) const { return m_rd_word; }
  dcItr GetDataIteratorBegin(void) const { return m_rd_data.begin(); }
  dcItr GetDataIteratorEnd(void) const { return m_rd_data.end(); }
};

#endif
