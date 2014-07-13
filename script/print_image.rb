#!/usr/bin/env ruby

STDIN.binmode

format = STDIN.gets.chomp
#comment = STDIN.gets.chomp
width, height = STDIN.gets.chomp.split.map { |i| i.to_i }
bits = STDIN.read

var_length = bits.length + 10

out = [
  "\x1d(L",
  var_length%256,
  var_length/256,
  48,
  112,
  48,
  1,
  1,
  49,
  width%256,
  width/256,
  height%256,
  height/256,
  bits
].pack("A*C12A*")

out += [
  "\x1d(L",
  2,
  0,
  48,
  50
].pack("A*C4")

print out
