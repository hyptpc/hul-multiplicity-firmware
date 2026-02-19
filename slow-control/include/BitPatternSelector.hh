// -*- C++ -*-

#ifndef BIT_PATTERN_SELECTOR_HH
#define BIT_PATTERN_SELECTOR_HH

#include "Uncopyable.hh"

#include <bitset>
#include <cstdint>
#include <vector>

//_____________________________________________________________________________
class BitPatternSelector : Uncopyable<BitPatternSelector>
{
public:
  ~BitPatternSelector( void );

private:
  BitPatternSelector( void );
  BitPatternSelector( BitPatternSelector& );
  BitPatternSelector operator =( BitPatternSelector& );
  static const uint32_t kMaxInputs = 16;

public:
  static uint32_t Coin( const std::vector<int>& val );
  static uint32_t Ctrl( const std::vector<int>& val );
};

#endif
