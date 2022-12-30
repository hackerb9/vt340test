#!/usr/bin/env python

charsets = [
  ('DEC Special','0',''),
  ('ASCII','B',''),
  ('DEC Technical','>',''),
  ('DEC Supplemental','%5',''),
  ('UPSS 94','<',''),
  ('UPSS 96','<','96'),
  ('ISO Latin-1','A','96'),

  ('British','A','nrcs'),
  ('Dutch','4','nrcs'),
  ('Finnish','5','nrcs'),
  ('Finnish','C','nrcs'),
  ('French','R','nrcs'),
  ('French Canadian','9','nrcs'),
  ('French Canadian','Q','nrcs'),
  ('German','K','nrcs'),
  ('Italian','Y','nrcs'),
  ('Norwegian/Danish','6','nrcs'),
  ('Norwegian/Danish','E','nrcs'),
  ('Norwegian/Danish','`','nrcs'),
  ('Portuguese','%6','nrcs'),
  ('Spanish','Z','nrcs'),
  ('Swedish','7','nrcs'),
  ('Swedish','H','nrcs'),
  ('Swiss','=','nrcs'),
]

def write(s):
  import sys
  sys.stdout.write(s)

def display(name,id,type):
  label = '%s (%s)' % (name,id)
  while len(label) < 22: label += ' '
  write(label)
  write('\x0E')
  write('\033)0')
  if type == '96':
    write('\033-%s' % id)
  else:
    write('\033)%s' % id)
  write('_#@[\\]^`{|}~')
  write('\x0F\n')

write('\033[?42h')
write('\033[2J\033[H')
write('\033[40COther\n\n')

for name,id,type in charsets:
  if type == 'nrcs': continue
  write('\033[40C')
  display(name,id,type)

write('\033[H')
write('NRCS\n\n')

for name,id,type in charsets:
  if type != 'nrcs': continue
  display(name,id,type)

write('\n')
write('\033[?42l')