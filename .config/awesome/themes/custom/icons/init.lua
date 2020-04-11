local dir = os.getenv('HOME') .. '/.config/awesome/themes/custom/icons'

return {
  awesome = dir .. '/awesome.png',
  close = dir .. '/close.svg',
  plus = dir .. '/plus.svg',
  -- Widgets
  volume = dir .. '/widgets/volume-high.svg',
  memory = dir .. '/widgets/memory.svg',
  cpu = dir .. '/widgets/cpu.svg',
  thermometer = dir .. '/widgets/thermometer.svg',
  note = dir .. '/widgets/note.png',
  note_on = dir .. '/widgets/note_on.png',
  brightness = dir .. '/widgets/brightness.svg',
  harddisk = dir .. '/widgets/harddisk.svg',
  -- Layouts
  floating = dir .. '/layouts/floating.png',
  tile = dir .. '/layouts/tile.png',
  tilebottom = dir .. '/layouts/tilebottom.png',
  tileleft = dir .. '/layouts/tileleft.png',
  tiletop = dir .. '/layouts/tiletop.png'
}
