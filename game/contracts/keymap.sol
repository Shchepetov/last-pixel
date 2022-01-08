// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

library ShareMapping {

  struct Map {
    address[] keys;
    mapping(address => uint) data;
    uint shares;
  }

  function increment(Map storage self, address key) internal {

    if (self.data[key] == 0)
      self.keys.push(key);
    self.data[key]++;
    self.shares++;
  }

  function clear(Map storage self) internal {

    for (uint i = 0; i < self.keys.length; i++)
      delete self.data[self.keys[i]];
    delete self.keys;
  }
}
