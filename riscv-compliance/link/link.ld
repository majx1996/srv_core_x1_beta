/*
    orininal code
*/
/*
OUTPUT_ARCH( "riscv" )
ENTRY(_start)

SECTIONS
{
  . = 0x00000000;
  .text.trap : { *(.text.trap) }

  . = 0x80000000;
  .text.init : { *(.text.init) }

  . = ALIGN(0x1000);
  .tohost : { *(.tohost) }
  . = ALIGN(0x1000);
  .text : { *(.text) }
  . = ALIGN(0x1000);
  .data : { *(.data) }
  .data.string : { *(.data.string)}
  .bss : { *(.bss) }
  _end = .;
}
*/

/*
    modified code
*/
OUTPUT_ARCH( "riscv" )
ENTRY(_start)

SECTIONS
{
  . = 0x80000000;
  .text.trap : { *(.text.trap) }
  . = ALIGN(0x1000);
  .text.init : { *(.text.init) }
  . = ALIGN(0x1000);
  .text : { *(.text) }

  . = 0x90000000;
  .data : { *(.data) }
  . = ALIGN(0x1000);
  .tohost : { *(.tohost) }
  . = ALIGN(0x1000);
  .data.string : { *(.data.string)}
  .bss : { *(.bss) }
  _end = .;
}


