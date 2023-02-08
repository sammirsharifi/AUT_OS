
kernel/kernel:     file format elf64-littleriscv


Disassembly of section .text:

0000000080000000 <_entry>:
    80000000:	00009117          	auipc	sp,0x9
    80000004:	a5010113          	addi	sp,sp,-1456 # 80008a50 <stack0>
    80000008:	6505                	lui	a0,0x1
    8000000a:	f14025f3          	csrr	a1,mhartid
    8000000e:	0585                	addi	a1,a1,1
    80000010:	02b50533          	mul	a0,a0,a1
    80000014:	912a                	add	sp,sp,a0
    80000016:	078000ef          	jal	ra,8000008e <start>

000000008000001a <spin>:
    8000001a:	a001                	j	8000001a <spin>

000000008000001c <timerinit>:
// at timervec in kernelvec.S,
// which turns them into software interrupts for
// devintr() in trap.c.
void
timerinit()
{
    8000001c:	1141                	addi	sp,sp,-16
    8000001e:	e422                	sd	s0,8(sp)
    80000020:	0800                	addi	s0,sp,16
// which hart (core) is this?
static inline uint64
r_mhartid()
{
  uint64 x;
  asm volatile("csrr %0, mhartid" : "=r" (x) );
    80000022:	f14027f3          	csrr	a5,mhartid
  // each CPU has a separate source of timer interrupts.
  int id = r_mhartid();
    80000026:	0007869b          	sext.w	a3,a5

  // ask the CLINT for a timer interrupt.
  int interval = 1000000; // cycles; about 1/10th second in qemu.
  *(uint64*)CLINT_MTIMECMP(id) = *(uint64*)CLINT_MTIME + interval;
    8000002a:	0037979b          	slliw	a5,a5,0x3
    8000002e:	02004737          	lui	a4,0x2004
    80000032:	97ba                	add	a5,a5,a4
    80000034:	0200c737          	lui	a4,0x200c
    80000038:	ff873583          	ld	a1,-8(a4) # 200bff8 <_entry-0x7dff4008>
    8000003c:	000f4637          	lui	a2,0xf4
    80000040:	24060613          	addi	a2,a2,576 # f4240 <_entry-0x7ff0bdc0>
    80000044:	95b2                	add	a1,a1,a2
    80000046:	e38c                	sd	a1,0(a5)

  // prepare information in scratch[] for timervec.
  // scratch[0..2] : space for timervec to save registers.
  // scratch[3] : address of CLINT MTIMECMP register.
  // scratch[4] : desired interval (in cycles) between timer interrupts.
  uint64 *scratch = &timer_scratch[id][0];
    80000048:	00269713          	slli	a4,a3,0x2
    8000004c:	9736                	add	a4,a4,a3
    8000004e:	00371693          	slli	a3,a4,0x3
    80000052:	00009717          	auipc	a4,0x9
    80000056:	8be70713          	addi	a4,a4,-1858 # 80008910 <timer_scratch>
    8000005a:	9736                	add	a4,a4,a3
  scratch[3] = CLINT_MTIMECMP(id);
    8000005c:	ef1c                	sd	a5,24(a4)
  scratch[4] = interval;
    8000005e:	f310                	sd	a2,32(a4)
}

static inline void 
w_mscratch(uint64 x)
{
  asm volatile("csrw mscratch, %0" : : "r" (x));
    80000060:	34071073          	csrw	mscratch,a4
  asm volatile("csrw mtvec, %0" : : "r" (x));
    80000064:	00006797          	auipc	a5,0x6
    80000068:	bcc78793          	addi	a5,a5,-1076 # 80005c30 <timervec>
    8000006c:	30579073          	csrw	mtvec,a5
  asm volatile("csrr %0, mstatus" : "=r" (x) );
    80000070:	300027f3          	csrr	a5,mstatus

  // set the machine-mode trap handler.
  w_mtvec((uint64)timervec);

  // enable machine-mode interrupts.
  w_mstatus(r_mstatus() | MSTATUS_MIE);
    80000074:	0087e793          	ori	a5,a5,8
  asm volatile("csrw mstatus, %0" : : "r" (x));
    80000078:	30079073          	csrw	mstatus,a5
  asm volatile("csrr %0, mie" : "=r" (x) );
    8000007c:	304027f3          	csrr	a5,mie

  // enable machine-mode timer interrupts.
  w_mie(r_mie() | MIE_MTIE);
    80000080:	0807e793          	ori	a5,a5,128
  asm volatile("csrw mie, %0" : : "r" (x));
    80000084:	30479073          	csrw	mie,a5
}
    80000088:	6422                	ld	s0,8(sp)
    8000008a:	0141                	addi	sp,sp,16
    8000008c:	8082                	ret

000000008000008e <start>:
{
    8000008e:	1141                	addi	sp,sp,-16
    80000090:	e406                	sd	ra,8(sp)
    80000092:	e022                	sd	s0,0(sp)
    80000094:	0800                	addi	s0,sp,16
  asm volatile("csrr %0, mstatus" : "=r" (x) );
    80000096:	300027f3          	csrr	a5,mstatus
  x &= ~MSTATUS_MPP_MASK;
    8000009a:	7779                	lui	a4,0xffffe
    8000009c:	7ff70713          	addi	a4,a4,2047 # ffffffffffffe7ff <end+0xffffffff7ffdca7f>
    800000a0:	8ff9                	and	a5,a5,a4
  x |= MSTATUS_MPP_S;
    800000a2:	6705                	lui	a4,0x1
    800000a4:	80070713          	addi	a4,a4,-2048 # 800 <_entry-0x7ffff800>
    800000a8:	8fd9                	or	a5,a5,a4
  asm volatile("csrw mstatus, %0" : : "r" (x));
    800000aa:	30079073          	csrw	mstatus,a5
  asm volatile("csrw mepc, %0" : : "r" (x));
    800000ae:	00001797          	auipc	a5,0x1
    800000b2:	e2e78793          	addi	a5,a5,-466 # 80000edc <main>
    800000b6:	34179073          	csrw	mepc,a5
  asm volatile("csrw satp, %0" : : "r" (x));
    800000ba:	4781                	li	a5,0
    800000bc:	18079073          	csrw	satp,a5
  asm volatile("csrw medeleg, %0" : : "r" (x));
    800000c0:	67c1                	lui	a5,0x10
    800000c2:	17fd                	addi	a5,a5,-1
    800000c4:	30279073          	csrw	medeleg,a5
  asm volatile("csrw mideleg, %0" : : "r" (x));
    800000c8:	30379073          	csrw	mideleg,a5
  asm volatile("csrr %0, sie" : "=r" (x) );
    800000cc:	104027f3          	csrr	a5,sie
  w_sie(r_sie() | SIE_SEIE | SIE_STIE | SIE_SSIE);
    800000d0:	2227e793          	ori	a5,a5,546
  asm volatile("csrw sie, %0" : : "r" (x));
    800000d4:	10479073          	csrw	sie,a5
  asm volatile("csrw pmpaddr0, %0" : : "r" (x));
    800000d8:	57fd                	li	a5,-1
    800000da:	83a9                	srli	a5,a5,0xa
    800000dc:	3b079073          	csrw	pmpaddr0,a5
  asm volatile("csrw pmpcfg0, %0" : : "r" (x));
    800000e0:	47bd                	li	a5,15
    800000e2:	3a079073          	csrw	pmpcfg0,a5
  timerinit();
    800000e6:	00000097          	auipc	ra,0x0
    800000ea:	f36080e7          	jalr	-202(ra) # 8000001c <timerinit>
  asm volatile("csrr %0, mhartid" : "=r" (x) );
    800000ee:	f14027f3          	csrr	a5,mhartid
  w_tp(id);
    800000f2:	2781                	sext.w	a5,a5
}

static inline void 
w_tp(uint64 x)
{
  asm volatile("mv tp, %0" : : "r" (x));
    800000f4:	823e                	mv	tp,a5
  asm volatile("mret");
    800000f6:	30200073          	mret
}
    800000fa:	60a2                	ld	ra,8(sp)
    800000fc:	6402                	ld	s0,0(sp)
    800000fe:	0141                	addi	sp,sp,16
    80000100:	8082                	ret

0000000080000102 <consolewrite>:
//
// user write()s to the console go here.
//
int
consolewrite(int user_src, uint64 src, int n)
{
    80000102:	715d                	addi	sp,sp,-80
    80000104:	e486                	sd	ra,72(sp)
    80000106:	e0a2                	sd	s0,64(sp)
    80000108:	fc26                	sd	s1,56(sp)
    8000010a:	f84a                	sd	s2,48(sp)
    8000010c:	f44e                	sd	s3,40(sp)
    8000010e:	f052                	sd	s4,32(sp)
    80000110:	ec56                	sd	s5,24(sp)
    80000112:	0880                	addi	s0,sp,80
  int i;

  for(i = 0; i < n; i++){
    80000114:	04c05663          	blez	a2,80000160 <consolewrite+0x5e>
    80000118:	8a2a                	mv	s4,a0
    8000011a:	84ae                	mv	s1,a1
    8000011c:	89b2                	mv	s3,a2
    8000011e:	4901                	li	s2,0
    char c;
    if(either_copyin(&c, user_src, src+i, 1) == -1)
    80000120:	5afd                	li	s5,-1
    80000122:	4685                	li	a3,1
    80000124:	8626                	mv	a2,s1
    80000126:	85d2                	mv	a1,s4
    80000128:	fbf40513          	addi	a0,s0,-65
    8000012c:	00002097          	auipc	ra,0x2
    80000130:	404080e7          	jalr	1028(ra) # 80002530 <either_copyin>
    80000134:	01550c63          	beq	a0,s5,8000014c <consolewrite+0x4a>
      break;
    uartputc(c);
    80000138:	fbf44503          	lbu	a0,-65(s0)
    8000013c:	00000097          	auipc	ra,0x0
    80000140:	780080e7          	jalr	1920(ra) # 800008bc <uartputc>
  for(i = 0; i < n; i++){
    80000144:	2905                	addiw	s2,s2,1
    80000146:	0485                	addi	s1,s1,1
    80000148:	fd299de3          	bne	s3,s2,80000122 <consolewrite+0x20>
  }

  return i;
}
    8000014c:	854a                	mv	a0,s2
    8000014e:	60a6                	ld	ra,72(sp)
    80000150:	6406                	ld	s0,64(sp)
    80000152:	74e2                	ld	s1,56(sp)
    80000154:	7942                	ld	s2,48(sp)
    80000156:	79a2                	ld	s3,40(sp)
    80000158:	7a02                	ld	s4,32(sp)
    8000015a:	6ae2                	ld	s5,24(sp)
    8000015c:	6161                	addi	sp,sp,80
    8000015e:	8082                	ret
  for(i = 0; i < n; i++){
    80000160:	4901                	li	s2,0
    80000162:	b7ed                	j	8000014c <consolewrite+0x4a>

0000000080000164 <consoleread>:
// user_dist indicates whether dst is a user
// or kernel address.
//
int
consoleread(int user_dst, uint64 dst, int n)
{
    80000164:	7159                	addi	sp,sp,-112
    80000166:	f486                	sd	ra,104(sp)
    80000168:	f0a2                	sd	s0,96(sp)
    8000016a:	eca6                	sd	s1,88(sp)
    8000016c:	e8ca                	sd	s2,80(sp)
    8000016e:	e4ce                	sd	s3,72(sp)
    80000170:	e0d2                	sd	s4,64(sp)
    80000172:	fc56                	sd	s5,56(sp)
    80000174:	f85a                	sd	s6,48(sp)
    80000176:	f45e                	sd	s7,40(sp)
    80000178:	f062                	sd	s8,32(sp)
    8000017a:	ec66                	sd	s9,24(sp)
    8000017c:	e86a                	sd	s10,16(sp)
    8000017e:	1880                	addi	s0,sp,112
    80000180:	8aaa                	mv	s5,a0
    80000182:	8a2e                	mv	s4,a1
    80000184:	89b2                	mv	s3,a2
  uint target;
  int c;
  char cbuf;

  target = n;
    80000186:	00060b1b          	sext.w	s6,a2
  acquire(&cons.lock);
    8000018a:	00011517          	auipc	a0,0x11
    8000018e:	8c650513          	addi	a0,a0,-1850 # 80010a50 <cons>
    80000192:	00001097          	auipc	ra,0x1
    80000196:	aa8080e7          	jalr	-1368(ra) # 80000c3a <acquire>
  while(n > 0){
    // wait until interrupt handler has put some
    // input into cons.buffer.
    while(cons.r == cons.w){
    8000019a:	00011497          	auipc	s1,0x11
    8000019e:	8b648493          	addi	s1,s1,-1866 # 80010a50 <cons>
      if(killed(myproc())){
        release(&cons.lock);
        return -1;
      }
      sleep(&cons.r, &cons.lock);
    800001a2:	00011917          	auipc	s2,0x11
    800001a6:	94690913          	addi	s2,s2,-1722 # 80010ae8 <cons+0x98>
    }

    c = cons.buf[cons.r++ % INPUT_BUF_SIZE];

    if(c == C('D')){  // end-of-file
    800001aa:	4b91                	li	s7,4
      break;
    }

    // copy the input byte to the user-space buffer.
    cbuf = c;
    if(either_copyout(user_dst, dst, &cbuf, 1) == -1)
    800001ac:	5c7d                	li	s8,-1
      break;

    dst++;
    --n;

    if(c == '\n'){
    800001ae:	4ca9                	li	s9,10
  while(n > 0){
    800001b0:	07305b63          	blez	s3,80000226 <consoleread+0xc2>
    while(cons.r == cons.w){
    800001b4:	0984a783          	lw	a5,152(s1)
    800001b8:	09c4a703          	lw	a4,156(s1)
    800001bc:	02f71763          	bne	a4,a5,800001ea <consoleread+0x86>
      if(killed(myproc())){
    800001c0:	00002097          	auipc	ra,0x2
    800001c4:	86a080e7          	jalr	-1942(ra) # 80001a2a <myproc>
    800001c8:	00002097          	auipc	ra,0x2
    800001cc:	1b2080e7          	jalr	434(ra) # 8000237a <killed>
    800001d0:	e535                	bnez	a0,8000023c <consoleread+0xd8>
      sleep(&cons.r, &cons.lock);
    800001d2:	85a6                	mv	a1,s1
    800001d4:	854a                	mv	a0,s2
    800001d6:	00002097          	auipc	ra,0x2
    800001da:	efc080e7          	jalr	-260(ra) # 800020d2 <sleep>
    while(cons.r == cons.w){
    800001de:	0984a783          	lw	a5,152(s1)
    800001e2:	09c4a703          	lw	a4,156(s1)
    800001e6:	fcf70de3          	beq	a4,a5,800001c0 <consoleread+0x5c>
    c = cons.buf[cons.r++ % INPUT_BUF_SIZE];
    800001ea:	0017871b          	addiw	a4,a5,1
    800001ee:	08e4ac23          	sw	a4,152(s1)
    800001f2:	07f7f713          	andi	a4,a5,127
    800001f6:	9726                	add	a4,a4,s1
    800001f8:	01874703          	lbu	a4,24(a4)
    800001fc:	00070d1b          	sext.w	s10,a4
    if(c == C('D')){  // end-of-file
    80000200:	077d0563          	beq	s10,s7,8000026a <consoleread+0x106>
    cbuf = c;
    80000204:	f8e40fa3          	sb	a4,-97(s0)
    if(either_copyout(user_dst, dst, &cbuf, 1) == -1)
    80000208:	4685                	li	a3,1
    8000020a:	f9f40613          	addi	a2,s0,-97
    8000020e:	85d2                	mv	a1,s4
    80000210:	8556                	mv	a0,s5
    80000212:	00002097          	auipc	ra,0x2
    80000216:	2c8080e7          	jalr	712(ra) # 800024da <either_copyout>
    8000021a:	01850663          	beq	a0,s8,80000226 <consoleread+0xc2>
    dst++;
    8000021e:	0a05                	addi	s4,s4,1
    --n;
    80000220:	39fd                	addiw	s3,s3,-1
    if(c == '\n'){
    80000222:	f99d17e3          	bne	s10,s9,800001b0 <consoleread+0x4c>
      // a whole line has arrived, return to
      // the user-level read().
      break;
    }
  }
  release(&cons.lock);
    80000226:	00011517          	auipc	a0,0x11
    8000022a:	82a50513          	addi	a0,a0,-2006 # 80010a50 <cons>
    8000022e:	00001097          	auipc	ra,0x1
    80000232:	ac0080e7          	jalr	-1344(ra) # 80000cee <release>

  return target - n;
    80000236:	413b053b          	subw	a0,s6,s3
    8000023a:	a811                	j	8000024e <consoleread+0xea>
        release(&cons.lock);
    8000023c:	00011517          	auipc	a0,0x11
    80000240:	81450513          	addi	a0,a0,-2028 # 80010a50 <cons>
    80000244:	00001097          	auipc	ra,0x1
    80000248:	aaa080e7          	jalr	-1366(ra) # 80000cee <release>
        return -1;
    8000024c:	557d                	li	a0,-1
}
    8000024e:	70a6                	ld	ra,104(sp)
    80000250:	7406                	ld	s0,96(sp)
    80000252:	64e6                	ld	s1,88(sp)
    80000254:	6946                	ld	s2,80(sp)
    80000256:	69a6                	ld	s3,72(sp)
    80000258:	6a06                	ld	s4,64(sp)
    8000025a:	7ae2                	ld	s5,56(sp)
    8000025c:	7b42                	ld	s6,48(sp)
    8000025e:	7ba2                	ld	s7,40(sp)
    80000260:	7c02                	ld	s8,32(sp)
    80000262:	6ce2                	ld	s9,24(sp)
    80000264:	6d42                	ld	s10,16(sp)
    80000266:	6165                	addi	sp,sp,112
    80000268:	8082                	ret
      if(n < target){
    8000026a:	0009871b          	sext.w	a4,s3
    8000026e:	fb677ce3          	bgeu	a4,s6,80000226 <consoleread+0xc2>
        cons.r--;
    80000272:	00011717          	auipc	a4,0x11
    80000276:	86f72b23          	sw	a5,-1930(a4) # 80010ae8 <cons+0x98>
    8000027a:	b775                	j	80000226 <consoleread+0xc2>

000000008000027c <consputc>:
{
    8000027c:	1141                	addi	sp,sp,-16
    8000027e:	e406                	sd	ra,8(sp)
    80000280:	e022                	sd	s0,0(sp)
    80000282:	0800                	addi	s0,sp,16
  if(c == BACKSPACE){
    80000284:	10000793          	li	a5,256
    80000288:	00f50a63          	beq	a0,a5,8000029c <consputc+0x20>
    uartputc_sync(c);
    8000028c:	00000097          	auipc	ra,0x0
    80000290:	55e080e7          	jalr	1374(ra) # 800007ea <uartputc_sync>
}
    80000294:	60a2                	ld	ra,8(sp)
    80000296:	6402                	ld	s0,0(sp)
    80000298:	0141                	addi	sp,sp,16
    8000029a:	8082                	ret
    uartputc_sync('\b'); uartputc_sync(' '); uartputc_sync('\b');
    8000029c:	4521                	li	a0,8
    8000029e:	00000097          	auipc	ra,0x0
    800002a2:	54c080e7          	jalr	1356(ra) # 800007ea <uartputc_sync>
    800002a6:	02000513          	li	a0,32
    800002aa:	00000097          	auipc	ra,0x0
    800002ae:	540080e7          	jalr	1344(ra) # 800007ea <uartputc_sync>
    800002b2:	4521                	li	a0,8
    800002b4:	00000097          	auipc	ra,0x0
    800002b8:	536080e7          	jalr	1334(ra) # 800007ea <uartputc_sync>
    800002bc:	bfe1                	j	80000294 <consputc+0x18>

00000000800002be <consoleintr>:
// do erase/kill processing, append to cons.buf,
// wake up consoleread() if a whole line has arrived.
//
void
consoleintr(int c)
{
    800002be:	1101                	addi	sp,sp,-32
    800002c0:	ec06                	sd	ra,24(sp)
    800002c2:	e822                	sd	s0,16(sp)
    800002c4:	e426                	sd	s1,8(sp)
    800002c6:	e04a                	sd	s2,0(sp)
    800002c8:	1000                	addi	s0,sp,32
    800002ca:	84aa                	mv	s1,a0
  acquire(&cons.lock);
    800002cc:	00010517          	auipc	a0,0x10
    800002d0:	78450513          	addi	a0,a0,1924 # 80010a50 <cons>
    800002d4:	00001097          	auipc	ra,0x1
    800002d8:	966080e7          	jalr	-1690(ra) # 80000c3a <acquire>

  switch(c){
    800002dc:	47d5                	li	a5,21
    800002de:	0af48663          	beq	s1,a5,8000038a <consoleintr+0xcc>
    800002e2:	0297ca63          	blt	a5,s1,80000316 <consoleintr+0x58>
    800002e6:	47a1                	li	a5,8
    800002e8:	0ef48763          	beq	s1,a5,800003d6 <consoleintr+0x118>
    800002ec:	47c1                	li	a5,16
    800002ee:	10f49a63          	bne	s1,a5,80000402 <consoleintr+0x144>
  case C('P'):  // Print process list.
    procdump();
    800002f2:	00002097          	auipc	ra,0x2
    800002f6:	294080e7          	jalr	660(ra) # 80002586 <procdump>
      }
    }
    break;
  }
  
  release(&cons.lock);
    800002fa:	00010517          	auipc	a0,0x10
    800002fe:	75650513          	addi	a0,a0,1878 # 80010a50 <cons>
    80000302:	00001097          	auipc	ra,0x1
    80000306:	9ec080e7          	jalr	-1556(ra) # 80000cee <release>
}
    8000030a:	60e2                	ld	ra,24(sp)
    8000030c:	6442                	ld	s0,16(sp)
    8000030e:	64a2                	ld	s1,8(sp)
    80000310:	6902                	ld	s2,0(sp)
    80000312:	6105                	addi	sp,sp,32
    80000314:	8082                	ret
  switch(c){
    80000316:	07f00793          	li	a5,127
    8000031a:	0af48e63          	beq	s1,a5,800003d6 <consoleintr+0x118>
    if(c != 0 && cons.e-cons.r < INPUT_BUF_SIZE){
    8000031e:	00010717          	auipc	a4,0x10
    80000322:	73270713          	addi	a4,a4,1842 # 80010a50 <cons>
    80000326:	0a072783          	lw	a5,160(a4)
    8000032a:	09872703          	lw	a4,152(a4)
    8000032e:	9f99                	subw	a5,a5,a4
    80000330:	07f00713          	li	a4,127
    80000334:	fcf763e3          	bltu	a4,a5,800002fa <consoleintr+0x3c>
      c = (c == '\r') ? '\n' : c;
    80000338:	47b5                	li	a5,13
    8000033a:	0cf48763          	beq	s1,a5,80000408 <consoleintr+0x14a>
      consputc(c);
    8000033e:	8526                	mv	a0,s1
    80000340:	00000097          	auipc	ra,0x0
    80000344:	f3c080e7          	jalr	-196(ra) # 8000027c <consputc>
      cons.buf[cons.e++ % INPUT_BUF_SIZE] = c;
    80000348:	00010797          	auipc	a5,0x10
    8000034c:	70878793          	addi	a5,a5,1800 # 80010a50 <cons>
    80000350:	0a07a683          	lw	a3,160(a5)
    80000354:	0016871b          	addiw	a4,a3,1
    80000358:	0007061b          	sext.w	a2,a4
    8000035c:	0ae7a023          	sw	a4,160(a5)
    80000360:	07f6f693          	andi	a3,a3,127
    80000364:	97b6                	add	a5,a5,a3
    80000366:	00978c23          	sb	s1,24(a5)
      if(c == '\n' || c == C('D') || cons.e-cons.r == INPUT_BUF_SIZE){
    8000036a:	47a9                	li	a5,10
    8000036c:	0cf48563          	beq	s1,a5,80000436 <consoleintr+0x178>
    80000370:	4791                	li	a5,4
    80000372:	0cf48263          	beq	s1,a5,80000436 <consoleintr+0x178>
    80000376:	00010797          	auipc	a5,0x10
    8000037a:	7727a783          	lw	a5,1906(a5) # 80010ae8 <cons+0x98>
    8000037e:	9f1d                	subw	a4,a4,a5
    80000380:	08000793          	li	a5,128
    80000384:	f6f71be3          	bne	a4,a5,800002fa <consoleintr+0x3c>
    80000388:	a07d                	j	80000436 <consoleintr+0x178>
    while(cons.e != cons.w &&
    8000038a:	00010717          	auipc	a4,0x10
    8000038e:	6c670713          	addi	a4,a4,1734 # 80010a50 <cons>
    80000392:	0a072783          	lw	a5,160(a4)
    80000396:	09c72703          	lw	a4,156(a4)
          cons.buf[(cons.e-1) % INPUT_BUF_SIZE] != '\n'){
    8000039a:	00010497          	auipc	s1,0x10
    8000039e:	6b648493          	addi	s1,s1,1718 # 80010a50 <cons>
    while(cons.e != cons.w &&
    800003a2:	4929                	li	s2,10
    800003a4:	f4f70be3          	beq	a4,a5,800002fa <consoleintr+0x3c>
          cons.buf[(cons.e-1) % INPUT_BUF_SIZE] != '\n'){
    800003a8:	37fd                	addiw	a5,a5,-1
    800003aa:	07f7f713          	andi	a4,a5,127
    800003ae:	9726                	add	a4,a4,s1
    while(cons.e != cons.w &&
    800003b0:	01874703          	lbu	a4,24(a4)
    800003b4:	f52703e3          	beq	a4,s2,800002fa <consoleintr+0x3c>
      cons.e--;
    800003b8:	0af4a023          	sw	a5,160(s1)
      consputc(BACKSPACE);
    800003bc:	10000513          	li	a0,256
    800003c0:	00000097          	auipc	ra,0x0
    800003c4:	ebc080e7          	jalr	-324(ra) # 8000027c <consputc>
    while(cons.e != cons.w &&
    800003c8:	0a04a783          	lw	a5,160(s1)
    800003cc:	09c4a703          	lw	a4,156(s1)
    800003d0:	fcf71ce3          	bne	a4,a5,800003a8 <consoleintr+0xea>
    800003d4:	b71d                	j	800002fa <consoleintr+0x3c>
    if(cons.e != cons.w){
    800003d6:	00010717          	auipc	a4,0x10
    800003da:	67a70713          	addi	a4,a4,1658 # 80010a50 <cons>
    800003de:	0a072783          	lw	a5,160(a4)
    800003e2:	09c72703          	lw	a4,156(a4)
    800003e6:	f0f70ae3          	beq	a4,a5,800002fa <consoleintr+0x3c>
      cons.e--;
    800003ea:	37fd                	addiw	a5,a5,-1
    800003ec:	00010717          	auipc	a4,0x10
    800003f0:	70f72223          	sw	a5,1796(a4) # 80010af0 <cons+0xa0>
      consputc(BACKSPACE);
    800003f4:	10000513          	li	a0,256
    800003f8:	00000097          	auipc	ra,0x0
    800003fc:	e84080e7          	jalr	-380(ra) # 8000027c <consputc>
    80000400:	bded                	j	800002fa <consoleintr+0x3c>
    if(c != 0 && cons.e-cons.r < INPUT_BUF_SIZE){
    80000402:	ee048ce3          	beqz	s1,800002fa <consoleintr+0x3c>
    80000406:	bf21                	j	8000031e <consoleintr+0x60>
      consputc(c);
    80000408:	4529                	li	a0,10
    8000040a:	00000097          	auipc	ra,0x0
    8000040e:	e72080e7          	jalr	-398(ra) # 8000027c <consputc>
      cons.buf[cons.e++ % INPUT_BUF_SIZE] = c;
    80000412:	00010797          	auipc	a5,0x10
    80000416:	63e78793          	addi	a5,a5,1598 # 80010a50 <cons>
    8000041a:	0a07a703          	lw	a4,160(a5)
    8000041e:	0017069b          	addiw	a3,a4,1
    80000422:	0006861b          	sext.w	a2,a3
    80000426:	0ad7a023          	sw	a3,160(a5)
    8000042a:	07f77713          	andi	a4,a4,127
    8000042e:	97ba                	add	a5,a5,a4
    80000430:	4729                	li	a4,10
    80000432:	00e78c23          	sb	a4,24(a5)
        cons.w = cons.e;
    80000436:	00010797          	auipc	a5,0x10
    8000043a:	6ac7ab23          	sw	a2,1718(a5) # 80010aec <cons+0x9c>
        wakeup(&cons.r);
    8000043e:	00010517          	auipc	a0,0x10
    80000442:	6aa50513          	addi	a0,a0,1706 # 80010ae8 <cons+0x98>
    80000446:	00002097          	auipc	ra,0x2
    8000044a:	cf0080e7          	jalr	-784(ra) # 80002136 <wakeup>
    8000044e:	b575                	j	800002fa <consoleintr+0x3c>

0000000080000450 <consoleinit>:

void
consoleinit(void)
{
    80000450:	1141                	addi	sp,sp,-16
    80000452:	e406                	sd	ra,8(sp)
    80000454:	e022                	sd	s0,0(sp)
    80000456:	0800                	addi	s0,sp,16
  initlock(&cons.lock, "cons");
    80000458:	00008597          	auipc	a1,0x8
    8000045c:	bb858593          	addi	a1,a1,-1096 # 80008010 <etext+0x10>
    80000460:	00010517          	auipc	a0,0x10
    80000464:	5f050513          	addi	a0,a0,1520 # 80010a50 <cons>
    80000468:	00000097          	auipc	ra,0x0
    8000046c:	742080e7          	jalr	1858(ra) # 80000baa <initlock>

  uartinit();
    80000470:	00000097          	auipc	ra,0x0
    80000474:	32a080e7          	jalr	810(ra) # 8000079a <uartinit>

  // connect read and write system calls
  // to consoleread and consolewrite.
  devsw[CONSOLE].read = consoleread;
    80000478:	00020797          	auipc	a5,0x20
    8000047c:	77078793          	addi	a5,a5,1904 # 80020be8 <devsw>
    80000480:	00000717          	auipc	a4,0x0
    80000484:	ce470713          	addi	a4,a4,-796 # 80000164 <consoleread>
    80000488:	eb98                	sd	a4,16(a5)
  devsw[CONSOLE].write = consolewrite;
    8000048a:	00000717          	auipc	a4,0x0
    8000048e:	c7870713          	addi	a4,a4,-904 # 80000102 <consolewrite>
    80000492:	ef98                	sd	a4,24(a5)
}
    80000494:	60a2                	ld	ra,8(sp)
    80000496:	6402                	ld	s0,0(sp)
    80000498:	0141                	addi	sp,sp,16
    8000049a:	8082                	ret

000000008000049c <printint>:

static char digits[] = "0123456789abcdef";

static void
printint(int xx, int base, int sign)
{
    8000049c:	7179                	addi	sp,sp,-48
    8000049e:	f406                	sd	ra,40(sp)
    800004a0:	f022                	sd	s0,32(sp)
    800004a2:	ec26                	sd	s1,24(sp)
    800004a4:	e84a                	sd	s2,16(sp)
    800004a6:	1800                	addi	s0,sp,48
  char buf[16];
  int i;
  uint x;

  if(sign && (sign = xx < 0))
    800004a8:	c219                	beqz	a2,800004ae <printint+0x12>
    800004aa:	08054663          	bltz	a0,80000536 <printint+0x9a>
    x = -xx;
  else
    x = xx;
    800004ae:	2501                	sext.w	a0,a0
    800004b0:	4881                	li	a7,0
    800004b2:	fd040693          	addi	a3,s0,-48

  i = 0;
    800004b6:	4701                	li	a4,0
  do {
    buf[i++] = digits[x % base];
    800004b8:	2581                	sext.w	a1,a1
    800004ba:	00008617          	auipc	a2,0x8
    800004be:	b8660613          	addi	a2,a2,-1146 # 80008040 <digits>
    800004c2:	883a                	mv	a6,a4
    800004c4:	2705                	addiw	a4,a4,1
    800004c6:	02b577bb          	remuw	a5,a0,a1
    800004ca:	1782                	slli	a5,a5,0x20
    800004cc:	9381                	srli	a5,a5,0x20
    800004ce:	97b2                	add	a5,a5,a2
    800004d0:	0007c783          	lbu	a5,0(a5)
    800004d4:	00f68023          	sb	a5,0(a3)
  } while((x /= base) != 0);
    800004d8:	0005079b          	sext.w	a5,a0
    800004dc:	02b5553b          	divuw	a0,a0,a1
    800004e0:	0685                	addi	a3,a3,1
    800004e2:	feb7f0e3          	bgeu	a5,a1,800004c2 <printint+0x26>

  if(sign)
    800004e6:	00088b63          	beqz	a7,800004fc <printint+0x60>
    buf[i++] = '-';
    800004ea:	fe040793          	addi	a5,s0,-32
    800004ee:	973e                	add	a4,a4,a5
    800004f0:	02d00793          	li	a5,45
    800004f4:	fef70823          	sb	a5,-16(a4)
    800004f8:	0028071b          	addiw	a4,a6,2

  while(--i >= 0)
    800004fc:	02e05763          	blez	a4,8000052a <printint+0x8e>
    80000500:	fd040793          	addi	a5,s0,-48
    80000504:	00e784b3          	add	s1,a5,a4
    80000508:	fff78913          	addi	s2,a5,-1
    8000050c:	993a                	add	s2,s2,a4
    8000050e:	377d                	addiw	a4,a4,-1
    80000510:	1702                	slli	a4,a4,0x20
    80000512:	9301                	srli	a4,a4,0x20
    80000514:	40e90933          	sub	s2,s2,a4
    consputc(buf[i]);
    80000518:	fff4c503          	lbu	a0,-1(s1)
    8000051c:	00000097          	auipc	ra,0x0
    80000520:	d60080e7          	jalr	-672(ra) # 8000027c <consputc>
  while(--i >= 0)
    80000524:	14fd                	addi	s1,s1,-1
    80000526:	ff2499e3          	bne	s1,s2,80000518 <printint+0x7c>
}
    8000052a:	70a2                	ld	ra,40(sp)
    8000052c:	7402                	ld	s0,32(sp)
    8000052e:	64e2                	ld	s1,24(sp)
    80000530:	6942                	ld	s2,16(sp)
    80000532:	6145                	addi	sp,sp,48
    80000534:	8082                	ret
    x = -xx;
    80000536:	40a0053b          	negw	a0,a0
  if(sign && (sign = xx < 0))
    8000053a:	4885                	li	a7,1
    x = -xx;
    8000053c:	bf9d                	j	800004b2 <printint+0x16>

000000008000053e <panic>:
    release(&pr.lock);
}

void
panic(char *s)
{
    8000053e:	1101                	addi	sp,sp,-32
    80000540:	ec06                	sd	ra,24(sp)
    80000542:	e822                	sd	s0,16(sp)
    80000544:	e426                	sd	s1,8(sp)
    80000546:	1000                	addi	s0,sp,32
    80000548:	84aa                	mv	s1,a0
  pr.locking = 0;
    8000054a:	00010797          	auipc	a5,0x10
    8000054e:	5c07a323          	sw	zero,1478(a5) # 80010b10 <pr+0x18>
  printf("panic: ");
    80000552:	00008517          	auipc	a0,0x8
    80000556:	ac650513          	addi	a0,a0,-1338 # 80008018 <etext+0x18>
    8000055a:	00000097          	auipc	ra,0x0
    8000055e:	02e080e7          	jalr	46(ra) # 80000588 <printf>
  printf(s);
    80000562:	8526                	mv	a0,s1
    80000564:	00000097          	auipc	ra,0x0
    80000568:	024080e7          	jalr	36(ra) # 80000588 <printf>
  printf("\n");
    8000056c:	00008517          	auipc	a0,0x8
    80000570:	b9450513          	addi	a0,a0,-1132 # 80008100 <digits+0xc0>
    80000574:	00000097          	auipc	ra,0x0
    80000578:	014080e7          	jalr	20(ra) # 80000588 <printf>
  panicked = 1; // freeze uart output from other CPUs
    8000057c:	4785                	li	a5,1
    8000057e:	00008717          	auipc	a4,0x8
    80000582:	34f72923          	sw	a5,850(a4) # 800088d0 <panicked>
  for(;;)
    80000586:	a001                	j	80000586 <panic+0x48>

0000000080000588 <printf>:
{
    80000588:	7131                	addi	sp,sp,-192
    8000058a:	fc86                	sd	ra,120(sp)
    8000058c:	f8a2                	sd	s0,112(sp)
    8000058e:	f4a6                	sd	s1,104(sp)
    80000590:	f0ca                	sd	s2,96(sp)
    80000592:	ecce                	sd	s3,88(sp)
    80000594:	e8d2                	sd	s4,80(sp)
    80000596:	e4d6                	sd	s5,72(sp)
    80000598:	e0da                	sd	s6,64(sp)
    8000059a:	fc5e                	sd	s7,56(sp)
    8000059c:	f862                	sd	s8,48(sp)
    8000059e:	f466                	sd	s9,40(sp)
    800005a0:	f06a                	sd	s10,32(sp)
    800005a2:	ec6e                	sd	s11,24(sp)
    800005a4:	0100                	addi	s0,sp,128
    800005a6:	8a2a                	mv	s4,a0
    800005a8:	e40c                	sd	a1,8(s0)
    800005aa:	e810                	sd	a2,16(s0)
    800005ac:	ec14                	sd	a3,24(s0)
    800005ae:	f018                	sd	a4,32(s0)
    800005b0:	f41c                	sd	a5,40(s0)
    800005b2:	03043823          	sd	a6,48(s0)
    800005b6:	03143c23          	sd	a7,56(s0)
  locking = pr.locking;
    800005ba:	00010d97          	auipc	s11,0x10
    800005be:	556dad83          	lw	s11,1366(s11) # 80010b10 <pr+0x18>
  if(locking)
    800005c2:	020d9b63          	bnez	s11,800005f8 <printf+0x70>
  if (fmt == 0)
    800005c6:	040a0263          	beqz	s4,8000060a <printf+0x82>
  va_start(ap, fmt);
    800005ca:	00840793          	addi	a5,s0,8
    800005ce:	f8f43423          	sd	a5,-120(s0)
  for(i = 0; (c = fmt[i] & 0xff) != 0; i++){
    800005d2:	000a4503          	lbu	a0,0(s4)
    800005d6:	14050f63          	beqz	a0,80000734 <printf+0x1ac>
    800005da:	4981                	li	s3,0
    if(c != '%'){
    800005dc:	02500a93          	li	s5,37
    switch(c){
    800005e0:	07000b93          	li	s7,112
  consputc('x');
    800005e4:	4d41                	li	s10,16
    consputc(digits[x >> (sizeof(uint64) * 8 - 4)]);
    800005e6:	00008b17          	auipc	s6,0x8
    800005ea:	a5ab0b13          	addi	s6,s6,-1446 # 80008040 <digits>
    switch(c){
    800005ee:	07300c93          	li	s9,115
    800005f2:	06400c13          	li	s8,100
    800005f6:	a82d                	j	80000630 <printf+0xa8>
    acquire(&pr.lock);
    800005f8:	00010517          	auipc	a0,0x10
    800005fc:	50050513          	addi	a0,a0,1280 # 80010af8 <pr>
    80000600:	00000097          	auipc	ra,0x0
    80000604:	63a080e7          	jalr	1594(ra) # 80000c3a <acquire>
    80000608:	bf7d                	j	800005c6 <printf+0x3e>
    panic("null fmt");
    8000060a:	00008517          	auipc	a0,0x8
    8000060e:	a1e50513          	addi	a0,a0,-1506 # 80008028 <etext+0x28>
    80000612:	00000097          	auipc	ra,0x0
    80000616:	f2c080e7          	jalr	-212(ra) # 8000053e <panic>
      consputc(c);
    8000061a:	00000097          	auipc	ra,0x0
    8000061e:	c62080e7          	jalr	-926(ra) # 8000027c <consputc>
  for(i = 0; (c = fmt[i] & 0xff) != 0; i++){
    80000622:	2985                	addiw	s3,s3,1
    80000624:	013a07b3          	add	a5,s4,s3
    80000628:	0007c503          	lbu	a0,0(a5)
    8000062c:	10050463          	beqz	a0,80000734 <printf+0x1ac>
    if(c != '%'){
    80000630:	ff5515e3          	bne	a0,s5,8000061a <printf+0x92>
    c = fmt[++i] & 0xff;
    80000634:	2985                	addiw	s3,s3,1
    80000636:	013a07b3          	add	a5,s4,s3
    8000063a:	0007c783          	lbu	a5,0(a5)
    8000063e:	0007849b          	sext.w	s1,a5
    if(c == 0)
    80000642:	cbed                	beqz	a5,80000734 <printf+0x1ac>
    switch(c){
    80000644:	05778a63          	beq	a5,s7,80000698 <printf+0x110>
    80000648:	02fbf663          	bgeu	s7,a5,80000674 <printf+0xec>
    8000064c:	09978863          	beq	a5,s9,800006dc <printf+0x154>
    80000650:	07800713          	li	a4,120
    80000654:	0ce79563          	bne	a5,a4,8000071e <printf+0x196>
      printint(va_arg(ap, int), 16, 1);
    80000658:	f8843783          	ld	a5,-120(s0)
    8000065c:	00878713          	addi	a4,a5,8
    80000660:	f8e43423          	sd	a4,-120(s0)
    80000664:	4605                	li	a2,1
    80000666:	85ea                	mv	a1,s10
    80000668:	4388                	lw	a0,0(a5)
    8000066a:	00000097          	auipc	ra,0x0
    8000066e:	e32080e7          	jalr	-462(ra) # 8000049c <printint>
      break;
    80000672:	bf45                	j	80000622 <printf+0x9a>
    switch(c){
    80000674:	09578f63          	beq	a5,s5,80000712 <printf+0x18a>
    80000678:	0b879363          	bne	a5,s8,8000071e <printf+0x196>
      printint(va_arg(ap, int), 10, 1);
    8000067c:	f8843783          	ld	a5,-120(s0)
    80000680:	00878713          	addi	a4,a5,8
    80000684:	f8e43423          	sd	a4,-120(s0)
    80000688:	4605                	li	a2,1
    8000068a:	45a9                	li	a1,10
    8000068c:	4388                	lw	a0,0(a5)
    8000068e:	00000097          	auipc	ra,0x0
    80000692:	e0e080e7          	jalr	-498(ra) # 8000049c <printint>
      break;
    80000696:	b771                	j	80000622 <printf+0x9a>
      printptr(va_arg(ap, uint64));
    80000698:	f8843783          	ld	a5,-120(s0)
    8000069c:	00878713          	addi	a4,a5,8
    800006a0:	f8e43423          	sd	a4,-120(s0)
    800006a4:	0007b903          	ld	s2,0(a5)
  consputc('0');
    800006a8:	03000513          	li	a0,48
    800006ac:	00000097          	auipc	ra,0x0
    800006b0:	bd0080e7          	jalr	-1072(ra) # 8000027c <consputc>
  consputc('x');
    800006b4:	07800513          	li	a0,120
    800006b8:	00000097          	auipc	ra,0x0
    800006bc:	bc4080e7          	jalr	-1084(ra) # 8000027c <consputc>
    800006c0:	84ea                	mv	s1,s10
    consputc(digits[x >> (sizeof(uint64) * 8 - 4)]);
    800006c2:	03c95793          	srli	a5,s2,0x3c
    800006c6:	97da                	add	a5,a5,s6
    800006c8:	0007c503          	lbu	a0,0(a5)
    800006cc:	00000097          	auipc	ra,0x0
    800006d0:	bb0080e7          	jalr	-1104(ra) # 8000027c <consputc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
    800006d4:	0912                	slli	s2,s2,0x4
    800006d6:	34fd                	addiw	s1,s1,-1
    800006d8:	f4ed                	bnez	s1,800006c2 <printf+0x13a>
    800006da:	b7a1                	j	80000622 <printf+0x9a>
      if((s = va_arg(ap, char*)) == 0)
    800006dc:	f8843783          	ld	a5,-120(s0)
    800006e0:	00878713          	addi	a4,a5,8
    800006e4:	f8e43423          	sd	a4,-120(s0)
    800006e8:	6384                	ld	s1,0(a5)
    800006ea:	cc89                	beqz	s1,80000704 <printf+0x17c>
      for(; *s; s++)
    800006ec:	0004c503          	lbu	a0,0(s1)
    800006f0:	d90d                	beqz	a0,80000622 <printf+0x9a>
        consputc(*s);
    800006f2:	00000097          	auipc	ra,0x0
    800006f6:	b8a080e7          	jalr	-1142(ra) # 8000027c <consputc>
      for(; *s; s++)
    800006fa:	0485                	addi	s1,s1,1
    800006fc:	0004c503          	lbu	a0,0(s1)
    80000700:	f96d                	bnez	a0,800006f2 <printf+0x16a>
    80000702:	b705                	j	80000622 <printf+0x9a>
        s = "(null)";
    80000704:	00008497          	auipc	s1,0x8
    80000708:	91c48493          	addi	s1,s1,-1764 # 80008020 <etext+0x20>
      for(; *s; s++)
    8000070c:	02800513          	li	a0,40
    80000710:	b7cd                	j	800006f2 <printf+0x16a>
      consputc('%');
    80000712:	8556                	mv	a0,s5
    80000714:	00000097          	auipc	ra,0x0
    80000718:	b68080e7          	jalr	-1176(ra) # 8000027c <consputc>
      break;
    8000071c:	b719                	j	80000622 <printf+0x9a>
      consputc('%');
    8000071e:	8556                	mv	a0,s5
    80000720:	00000097          	auipc	ra,0x0
    80000724:	b5c080e7          	jalr	-1188(ra) # 8000027c <consputc>
      consputc(c);
    80000728:	8526                	mv	a0,s1
    8000072a:	00000097          	auipc	ra,0x0
    8000072e:	b52080e7          	jalr	-1198(ra) # 8000027c <consputc>
      break;
    80000732:	bdc5                	j	80000622 <printf+0x9a>
  if(locking)
    80000734:	020d9163          	bnez	s11,80000756 <printf+0x1ce>
}
    80000738:	70e6                	ld	ra,120(sp)
    8000073a:	7446                	ld	s0,112(sp)
    8000073c:	74a6                	ld	s1,104(sp)
    8000073e:	7906                	ld	s2,96(sp)
    80000740:	69e6                	ld	s3,88(sp)
    80000742:	6a46                	ld	s4,80(sp)
    80000744:	6aa6                	ld	s5,72(sp)
    80000746:	6b06                	ld	s6,64(sp)
    80000748:	7be2                	ld	s7,56(sp)
    8000074a:	7c42                	ld	s8,48(sp)
    8000074c:	7ca2                	ld	s9,40(sp)
    8000074e:	7d02                	ld	s10,32(sp)
    80000750:	6de2                	ld	s11,24(sp)
    80000752:	6129                	addi	sp,sp,192
    80000754:	8082                	ret
    release(&pr.lock);
    80000756:	00010517          	auipc	a0,0x10
    8000075a:	3a250513          	addi	a0,a0,930 # 80010af8 <pr>
    8000075e:	00000097          	auipc	ra,0x0
    80000762:	590080e7          	jalr	1424(ra) # 80000cee <release>
}
    80000766:	bfc9                	j	80000738 <printf+0x1b0>

0000000080000768 <printfinit>:
    ;
}

void
printfinit(void)
{
    80000768:	1101                	addi	sp,sp,-32
    8000076a:	ec06                	sd	ra,24(sp)
    8000076c:	e822                	sd	s0,16(sp)
    8000076e:	e426                	sd	s1,8(sp)
    80000770:	1000                	addi	s0,sp,32
  initlock(&pr.lock, "pr");
    80000772:	00010497          	auipc	s1,0x10
    80000776:	38648493          	addi	s1,s1,902 # 80010af8 <pr>
    8000077a:	00008597          	auipc	a1,0x8
    8000077e:	8be58593          	addi	a1,a1,-1858 # 80008038 <etext+0x38>
    80000782:	8526                	mv	a0,s1
    80000784:	00000097          	auipc	ra,0x0
    80000788:	426080e7          	jalr	1062(ra) # 80000baa <initlock>
  pr.locking = 1;
    8000078c:	4785                	li	a5,1
    8000078e:	cc9c                	sw	a5,24(s1)
}
    80000790:	60e2                	ld	ra,24(sp)
    80000792:	6442                	ld	s0,16(sp)
    80000794:	64a2                	ld	s1,8(sp)
    80000796:	6105                	addi	sp,sp,32
    80000798:	8082                	ret

000000008000079a <uartinit>:

void uartstart();

void
uartinit(void)
{
    8000079a:	1141                	addi	sp,sp,-16
    8000079c:	e406                	sd	ra,8(sp)
    8000079e:	e022                	sd	s0,0(sp)
    800007a0:	0800                	addi	s0,sp,16
  // disable interrupts.
  WriteReg(IER, 0x00);
    800007a2:	100007b7          	lui	a5,0x10000
    800007a6:	000780a3          	sb	zero,1(a5) # 10000001 <_entry-0x6fffffff>

  // special mode to set baud rate.
  WriteReg(LCR, LCR_BAUD_LATCH);
    800007aa:	f8000713          	li	a4,-128
    800007ae:	00e781a3          	sb	a4,3(a5)

  // LSB for baud rate of 38.4K.
  WriteReg(0, 0x03);
    800007b2:	470d                	li	a4,3
    800007b4:	00e78023          	sb	a4,0(a5)

  // MSB for baud rate of 38.4K.
  WriteReg(1, 0x00);
    800007b8:	000780a3          	sb	zero,1(a5)

  // leave set-baud mode,
  // and set word length to 8 bits, no parity.
  WriteReg(LCR, LCR_EIGHT_BITS);
    800007bc:	00e781a3          	sb	a4,3(a5)

  // reset and enable FIFOs.
  WriteReg(FCR, FCR_FIFO_ENABLE | FCR_FIFO_CLEAR);
    800007c0:	469d                	li	a3,7
    800007c2:	00d78123          	sb	a3,2(a5)

  // enable transmit and receive interrupts.
  WriteReg(IER, IER_TX_ENABLE | IER_RX_ENABLE);
    800007c6:	00e780a3          	sb	a4,1(a5)

  initlock(&uart_tx_lock, "uart");
    800007ca:	00008597          	auipc	a1,0x8
    800007ce:	88e58593          	addi	a1,a1,-1906 # 80008058 <digits+0x18>
    800007d2:	00010517          	auipc	a0,0x10
    800007d6:	34650513          	addi	a0,a0,838 # 80010b18 <uart_tx_lock>
    800007da:	00000097          	auipc	ra,0x0
    800007de:	3d0080e7          	jalr	976(ra) # 80000baa <initlock>
}
    800007e2:	60a2                	ld	ra,8(sp)
    800007e4:	6402                	ld	s0,0(sp)
    800007e6:	0141                	addi	sp,sp,16
    800007e8:	8082                	ret

00000000800007ea <uartputc_sync>:
// use interrupts, for use by kernel printf() and
// to echo characters. it spins waiting for the uart's
// output register to be empty.
void
uartputc_sync(int c)
{
    800007ea:	1101                	addi	sp,sp,-32
    800007ec:	ec06                	sd	ra,24(sp)
    800007ee:	e822                	sd	s0,16(sp)
    800007f0:	e426                	sd	s1,8(sp)
    800007f2:	1000                	addi	s0,sp,32
    800007f4:	84aa                	mv	s1,a0
  push_off();
    800007f6:	00000097          	auipc	ra,0x0
    800007fa:	3f8080e7          	jalr	1016(ra) # 80000bee <push_off>

  if(panicked){
    800007fe:	00008797          	auipc	a5,0x8
    80000802:	0d27a783          	lw	a5,210(a5) # 800088d0 <panicked>
    for(;;)
      ;
  }

  // wait for Transmit Holding Empty to be set in LSR.
  while((ReadReg(LSR) & LSR_TX_IDLE) == 0)
    80000806:	10000737          	lui	a4,0x10000
  if(panicked){
    8000080a:	c391                	beqz	a5,8000080e <uartputc_sync+0x24>
    for(;;)
    8000080c:	a001                	j	8000080c <uartputc_sync+0x22>
  while((ReadReg(LSR) & LSR_TX_IDLE) == 0)
    8000080e:	00574783          	lbu	a5,5(a4) # 10000005 <_entry-0x6ffffffb>
    80000812:	0207f793          	andi	a5,a5,32
    80000816:	dfe5                	beqz	a5,8000080e <uartputc_sync+0x24>
    ;
  WriteReg(THR, c);
    80000818:	0ff4f513          	andi	a0,s1,255
    8000081c:	100007b7          	lui	a5,0x10000
    80000820:	00a78023          	sb	a0,0(a5) # 10000000 <_entry-0x70000000>

  pop_off();
    80000824:	00000097          	auipc	ra,0x0
    80000828:	46a080e7          	jalr	1130(ra) # 80000c8e <pop_off>
}
    8000082c:	60e2                	ld	ra,24(sp)
    8000082e:	6442                	ld	s0,16(sp)
    80000830:	64a2                	ld	s1,8(sp)
    80000832:	6105                	addi	sp,sp,32
    80000834:	8082                	ret

0000000080000836 <uartstart>:
// called from both the top- and bottom-half.
void
uartstart()
{
  while(1){
    if(uart_tx_w == uart_tx_r){
    80000836:	00008797          	auipc	a5,0x8
    8000083a:	0a27b783          	ld	a5,162(a5) # 800088d8 <uart_tx_r>
    8000083e:	00008717          	auipc	a4,0x8
    80000842:	0a273703          	ld	a4,162(a4) # 800088e0 <uart_tx_w>
    80000846:	06f70a63          	beq	a4,a5,800008ba <uartstart+0x84>
{
    8000084a:	7139                	addi	sp,sp,-64
    8000084c:	fc06                	sd	ra,56(sp)
    8000084e:	f822                	sd	s0,48(sp)
    80000850:	f426                	sd	s1,40(sp)
    80000852:	f04a                	sd	s2,32(sp)
    80000854:	ec4e                	sd	s3,24(sp)
    80000856:	e852                	sd	s4,16(sp)
    80000858:	e456                	sd	s5,8(sp)
    8000085a:	0080                	addi	s0,sp,64
      // transmit buffer is empty.
      return;
    }
    
    if((ReadReg(LSR) & LSR_TX_IDLE) == 0){
    8000085c:	10000937          	lui	s2,0x10000
      // so we cannot give it another byte.
      // it will interrupt when it's ready for a new byte.
      return;
    }
    
    int c = uart_tx_buf[uart_tx_r % UART_TX_BUF_SIZE];
    80000860:	00010a17          	auipc	s4,0x10
    80000864:	2b8a0a13          	addi	s4,s4,696 # 80010b18 <uart_tx_lock>
    uart_tx_r += 1;
    80000868:	00008497          	auipc	s1,0x8
    8000086c:	07048493          	addi	s1,s1,112 # 800088d8 <uart_tx_r>
    if(uart_tx_w == uart_tx_r){
    80000870:	00008997          	auipc	s3,0x8
    80000874:	07098993          	addi	s3,s3,112 # 800088e0 <uart_tx_w>
    if((ReadReg(LSR) & LSR_TX_IDLE) == 0){
    80000878:	00594703          	lbu	a4,5(s2) # 10000005 <_entry-0x6ffffffb>
    8000087c:	02077713          	andi	a4,a4,32
    80000880:	c705                	beqz	a4,800008a8 <uartstart+0x72>
    int c = uart_tx_buf[uart_tx_r % UART_TX_BUF_SIZE];
    80000882:	01f7f713          	andi	a4,a5,31
    80000886:	9752                	add	a4,a4,s4
    80000888:	01874a83          	lbu	s5,24(a4)
    uart_tx_r += 1;
    8000088c:	0785                	addi	a5,a5,1
    8000088e:	e09c                	sd	a5,0(s1)
    
    // maybe uartputc() is waiting for space in the buffer.
    wakeup(&uart_tx_r);
    80000890:	8526                	mv	a0,s1
    80000892:	00002097          	auipc	ra,0x2
    80000896:	8a4080e7          	jalr	-1884(ra) # 80002136 <wakeup>
    
    WriteReg(THR, c);
    8000089a:	01590023          	sb	s5,0(s2)
    if(uart_tx_w == uart_tx_r){
    8000089e:	609c                	ld	a5,0(s1)
    800008a0:	0009b703          	ld	a4,0(s3)
    800008a4:	fcf71ae3          	bne	a4,a5,80000878 <uartstart+0x42>
  }
}
    800008a8:	70e2                	ld	ra,56(sp)
    800008aa:	7442                	ld	s0,48(sp)
    800008ac:	74a2                	ld	s1,40(sp)
    800008ae:	7902                	ld	s2,32(sp)
    800008b0:	69e2                	ld	s3,24(sp)
    800008b2:	6a42                	ld	s4,16(sp)
    800008b4:	6aa2                	ld	s5,8(sp)
    800008b6:	6121                	addi	sp,sp,64
    800008b8:	8082                	ret
    800008ba:	8082                	ret

00000000800008bc <uartputc>:
{
    800008bc:	7179                	addi	sp,sp,-48
    800008be:	f406                	sd	ra,40(sp)
    800008c0:	f022                	sd	s0,32(sp)
    800008c2:	ec26                	sd	s1,24(sp)
    800008c4:	e84a                	sd	s2,16(sp)
    800008c6:	e44e                	sd	s3,8(sp)
    800008c8:	e052                	sd	s4,0(sp)
    800008ca:	1800                	addi	s0,sp,48
    800008cc:	8a2a                	mv	s4,a0
  acquire(&uart_tx_lock);
    800008ce:	00010517          	auipc	a0,0x10
    800008d2:	24a50513          	addi	a0,a0,586 # 80010b18 <uart_tx_lock>
    800008d6:	00000097          	auipc	ra,0x0
    800008da:	364080e7          	jalr	868(ra) # 80000c3a <acquire>
  if(panicked){
    800008de:	00008797          	auipc	a5,0x8
    800008e2:	ff27a783          	lw	a5,-14(a5) # 800088d0 <panicked>
    800008e6:	e7c9                	bnez	a5,80000970 <uartputc+0xb4>
  while(uart_tx_w == uart_tx_r + UART_TX_BUF_SIZE){
    800008e8:	00008717          	auipc	a4,0x8
    800008ec:	ff873703          	ld	a4,-8(a4) # 800088e0 <uart_tx_w>
    800008f0:	00008797          	auipc	a5,0x8
    800008f4:	fe87b783          	ld	a5,-24(a5) # 800088d8 <uart_tx_r>
    800008f8:	02078793          	addi	a5,a5,32
    sleep(&uart_tx_r, &uart_tx_lock);
    800008fc:	00010997          	auipc	s3,0x10
    80000900:	21c98993          	addi	s3,s3,540 # 80010b18 <uart_tx_lock>
    80000904:	00008497          	auipc	s1,0x8
    80000908:	fd448493          	addi	s1,s1,-44 # 800088d8 <uart_tx_r>
  while(uart_tx_w == uart_tx_r + UART_TX_BUF_SIZE){
    8000090c:	00008917          	auipc	s2,0x8
    80000910:	fd490913          	addi	s2,s2,-44 # 800088e0 <uart_tx_w>
    80000914:	00e79f63          	bne	a5,a4,80000932 <uartputc+0x76>
    sleep(&uart_tx_r, &uart_tx_lock);
    80000918:	85ce                	mv	a1,s3
    8000091a:	8526                	mv	a0,s1
    8000091c:	00001097          	auipc	ra,0x1
    80000920:	7b6080e7          	jalr	1974(ra) # 800020d2 <sleep>
  while(uart_tx_w == uart_tx_r + UART_TX_BUF_SIZE){
    80000924:	00093703          	ld	a4,0(s2)
    80000928:	609c                	ld	a5,0(s1)
    8000092a:	02078793          	addi	a5,a5,32
    8000092e:	fee785e3          	beq	a5,a4,80000918 <uartputc+0x5c>
  uart_tx_buf[uart_tx_w % UART_TX_BUF_SIZE] = c;
    80000932:	00010497          	auipc	s1,0x10
    80000936:	1e648493          	addi	s1,s1,486 # 80010b18 <uart_tx_lock>
    8000093a:	01f77793          	andi	a5,a4,31
    8000093e:	97a6                	add	a5,a5,s1
    80000940:	01478c23          	sb	s4,24(a5)
  uart_tx_w += 1;
    80000944:	0705                	addi	a4,a4,1
    80000946:	00008797          	auipc	a5,0x8
    8000094a:	f8e7bd23          	sd	a4,-102(a5) # 800088e0 <uart_tx_w>
  uartstart();
    8000094e:	00000097          	auipc	ra,0x0
    80000952:	ee8080e7          	jalr	-280(ra) # 80000836 <uartstart>
  release(&uart_tx_lock);
    80000956:	8526                	mv	a0,s1
    80000958:	00000097          	auipc	ra,0x0
    8000095c:	396080e7          	jalr	918(ra) # 80000cee <release>
}
    80000960:	70a2                	ld	ra,40(sp)
    80000962:	7402                	ld	s0,32(sp)
    80000964:	64e2                	ld	s1,24(sp)
    80000966:	6942                	ld	s2,16(sp)
    80000968:	69a2                	ld	s3,8(sp)
    8000096a:	6a02                	ld	s4,0(sp)
    8000096c:	6145                	addi	sp,sp,48
    8000096e:	8082                	ret
    for(;;)
    80000970:	a001                	j	80000970 <uartputc+0xb4>

0000000080000972 <uartgetc>:

// read one input character from the UART.
// return -1 if none is waiting.
int
uartgetc(void)
{
    80000972:	1141                	addi	sp,sp,-16
    80000974:	e422                	sd	s0,8(sp)
    80000976:	0800                	addi	s0,sp,16
  if(ReadReg(LSR) & 0x01){
    80000978:	100007b7          	lui	a5,0x10000
    8000097c:	0057c783          	lbu	a5,5(a5) # 10000005 <_entry-0x6ffffffb>
    80000980:	8b85                	andi	a5,a5,1
    80000982:	cb91                	beqz	a5,80000996 <uartgetc+0x24>
    // input data is ready.
    return ReadReg(RHR);
    80000984:	100007b7          	lui	a5,0x10000
    80000988:	0007c503          	lbu	a0,0(a5) # 10000000 <_entry-0x70000000>
    8000098c:	0ff57513          	andi	a0,a0,255
  } else {
    return -1;
  }
}
    80000990:	6422                	ld	s0,8(sp)
    80000992:	0141                	addi	sp,sp,16
    80000994:	8082                	ret
    return -1;
    80000996:	557d                	li	a0,-1
    80000998:	bfe5                	j	80000990 <uartgetc+0x1e>

000000008000099a <uartintr>:
// handle a uart interrupt, raised because input has
// arrived, or the uart is ready for more output, or
// both. called from devintr().
void
uartintr(void)
{
    8000099a:	1101                	addi	sp,sp,-32
    8000099c:	ec06                	sd	ra,24(sp)
    8000099e:	e822                	sd	s0,16(sp)
    800009a0:	e426                	sd	s1,8(sp)
    800009a2:	1000                	addi	s0,sp,32
  // read and process incoming characters.
  while(1){
    int c = uartgetc();
    if(c == -1)
    800009a4:	54fd                	li	s1,-1
    800009a6:	a029                	j	800009b0 <uartintr+0x16>
      break;
    consoleintr(c);
    800009a8:	00000097          	auipc	ra,0x0
    800009ac:	916080e7          	jalr	-1770(ra) # 800002be <consoleintr>
    int c = uartgetc();
    800009b0:	00000097          	auipc	ra,0x0
    800009b4:	fc2080e7          	jalr	-62(ra) # 80000972 <uartgetc>
    if(c == -1)
    800009b8:	fe9518e3          	bne	a0,s1,800009a8 <uartintr+0xe>
  }

  // send buffered characters.
  acquire(&uart_tx_lock);
    800009bc:	00010497          	auipc	s1,0x10
    800009c0:	15c48493          	addi	s1,s1,348 # 80010b18 <uart_tx_lock>
    800009c4:	8526                	mv	a0,s1
    800009c6:	00000097          	auipc	ra,0x0
    800009ca:	274080e7          	jalr	628(ra) # 80000c3a <acquire>
  uartstart();
    800009ce:	00000097          	auipc	ra,0x0
    800009d2:	e68080e7          	jalr	-408(ra) # 80000836 <uartstart>
  release(&uart_tx_lock);
    800009d6:	8526                	mv	a0,s1
    800009d8:	00000097          	auipc	ra,0x0
    800009dc:	316080e7          	jalr	790(ra) # 80000cee <release>
}
    800009e0:	60e2                	ld	ra,24(sp)
    800009e2:	6442                	ld	s0,16(sp)
    800009e4:	64a2                	ld	s1,8(sp)
    800009e6:	6105                	addi	sp,sp,32
    800009e8:	8082                	ret

00000000800009ea <kfree>:
// which normally should have been returned by a
// call to kalloc().  (The exception is when
// initializing the allocator; see kinit above.)
void
kfree(void *pa)
{
    800009ea:	1101                	addi	sp,sp,-32
    800009ec:	ec06                	sd	ra,24(sp)
    800009ee:	e822                	sd	s0,16(sp)
    800009f0:	e426                	sd	s1,8(sp)
    800009f2:	e04a                	sd	s2,0(sp)
    800009f4:	1000                	addi	s0,sp,32
  struct run *r;

  if(((uint64)pa % PGSIZE) != 0 || (char*)pa < end || (uint64)pa >= PHYSTOP)
    800009f6:	03451793          	slli	a5,a0,0x34
    800009fa:	ebb9                	bnez	a5,80000a50 <kfree+0x66>
    800009fc:	84aa                	mv	s1,a0
    800009fe:	00021797          	auipc	a5,0x21
    80000a02:	38278793          	addi	a5,a5,898 # 80021d80 <end>
    80000a06:	04f56563          	bltu	a0,a5,80000a50 <kfree+0x66>
    80000a0a:	47c5                	li	a5,17
    80000a0c:	07ee                	slli	a5,a5,0x1b
    80000a0e:	04f57163          	bgeu	a0,a5,80000a50 <kfree+0x66>
    panic("kfree");

  // Fill with junk to catch dangling refs.
  memset(pa, 1, PGSIZE);
    80000a12:	6605                	lui	a2,0x1
    80000a14:	4585                	li	a1,1
    80000a16:	00000097          	auipc	ra,0x0
    80000a1a:	320080e7          	jalr	800(ra) # 80000d36 <memset>

  r = (struct run*)pa;

  acquire(&kmem.lock);
    80000a1e:	00010917          	auipc	s2,0x10
    80000a22:	13290913          	addi	s2,s2,306 # 80010b50 <kmem>
    80000a26:	854a                	mv	a0,s2
    80000a28:	00000097          	auipc	ra,0x0
    80000a2c:	212080e7          	jalr	530(ra) # 80000c3a <acquire>
  r->next = kmem.freelist;
    80000a30:	01893783          	ld	a5,24(s2)
    80000a34:	e09c                	sd	a5,0(s1)
  kmem.freelist = r;
    80000a36:	00993c23          	sd	s1,24(s2)
  release(&kmem.lock);
    80000a3a:	854a                	mv	a0,s2
    80000a3c:	00000097          	auipc	ra,0x0
    80000a40:	2b2080e7          	jalr	690(ra) # 80000cee <release>
}
    80000a44:	60e2                	ld	ra,24(sp)
    80000a46:	6442                	ld	s0,16(sp)
    80000a48:	64a2                	ld	s1,8(sp)
    80000a4a:	6902                	ld	s2,0(sp)
    80000a4c:	6105                	addi	sp,sp,32
    80000a4e:	8082                	ret
    panic("kfree");
    80000a50:	00007517          	auipc	a0,0x7
    80000a54:	61050513          	addi	a0,a0,1552 # 80008060 <digits+0x20>
    80000a58:	00000097          	auipc	ra,0x0
    80000a5c:	ae6080e7          	jalr	-1306(ra) # 8000053e <panic>

0000000080000a60 <freerange>:
{
    80000a60:	7179                	addi	sp,sp,-48
    80000a62:	f406                	sd	ra,40(sp)
    80000a64:	f022                	sd	s0,32(sp)
    80000a66:	ec26                	sd	s1,24(sp)
    80000a68:	e84a                	sd	s2,16(sp)
    80000a6a:	e44e                	sd	s3,8(sp)
    80000a6c:	e052                	sd	s4,0(sp)
    80000a6e:	1800                	addi	s0,sp,48
  p = (char*)PGROUNDUP((uint64)pa_start);
    80000a70:	6785                	lui	a5,0x1
    80000a72:	fff78493          	addi	s1,a5,-1 # fff <_entry-0x7ffff001>
    80000a76:	94aa                	add	s1,s1,a0
    80000a78:	757d                	lui	a0,0xfffff
    80000a7a:	8ce9                	and	s1,s1,a0
  for(; p + PGSIZE <= (char*)pa_end; p += PGSIZE)
    80000a7c:	94be                	add	s1,s1,a5
    80000a7e:	0095ee63          	bltu	a1,s1,80000a9a <freerange+0x3a>
    80000a82:	892e                	mv	s2,a1
    kfree(p);
    80000a84:	7a7d                	lui	s4,0xfffff
  for(; p + PGSIZE <= (char*)pa_end; p += PGSIZE)
    80000a86:	6985                	lui	s3,0x1
    kfree(p);
    80000a88:	01448533          	add	a0,s1,s4
    80000a8c:	00000097          	auipc	ra,0x0
    80000a90:	f5e080e7          	jalr	-162(ra) # 800009ea <kfree>
  for(; p + PGSIZE <= (char*)pa_end; p += PGSIZE)
    80000a94:	94ce                	add	s1,s1,s3
    80000a96:	fe9979e3          	bgeu	s2,s1,80000a88 <freerange+0x28>
}
    80000a9a:	70a2                	ld	ra,40(sp)
    80000a9c:	7402                	ld	s0,32(sp)
    80000a9e:	64e2                	ld	s1,24(sp)
    80000aa0:	6942                	ld	s2,16(sp)
    80000aa2:	69a2                	ld	s3,8(sp)
    80000aa4:	6a02                	ld	s4,0(sp)
    80000aa6:	6145                	addi	sp,sp,48
    80000aa8:	8082                	ret

0000000080000aaa <kinit>:
{
    80000aaa:	1141                	addi	sp,sp,-16
    80000aac:	e406                	sd	ra,8(sp)
    80000aae:	e022                	sd	s0,0(sp)
    80000ab0:	0800                	addi	s0,sp,16
  initlock(&kmem.lock, "kmem");
    80000ab2:	00007597          	auipc	a1,0x7
    80000ab6:	5b658593          	addi	a1,a1,1462 # 80008068 <digits+0x28>
    80000aba:	00010517          	auipc	a0,0x10
    80000abe:	09650513          	addi	a0,a0,150 # 80010b50 <kmem>
    80000ac2:	00000097          	auipc	ra,0x0
    80000ac6:	0e8080e7          	jalr	232(ra) # 80000baa <initlock>
  freerange(end, (void*)PHYSTOP);
    80000aca:	45c5                	li	a1,17
    80000acc:	05ee                	slli	a1,a1,0x1b
    80000ace:	00021517          	auipc	a0,0x21
    80000ad2:	2b250513          	addi	a0,a0,690 # 80021d80 <end>
    80000ad6:	00000097          	auipc	ra,0x0
    80000ada:	f8a080e7          	jalr	-118(ra) # 80000a60 <freerange>
}
    80000ade:	60a2                	ld	ra,8(sp)
    80000ae0:	6402                	ld	s0,0(sp)
    80000ae2:	0141                	addi	sp,sp,16
    80000ae4:	8082                	ret

0000000080000ae6 <kalloc>:
// Allocate one 4096-byte page of physical memory.
// Returns a pointer that the kernel can use.
// Returns 0 if the memory cannot be allocated.
void *
kalloc(void)
{
    80000ae6:	1101                	addi	sp,sp,-32
    80000ae8:	ec06                	sd	ra,24(sp)
    80000aea:	e822                	sd	s0,16(sp)
    80000aec:	e426                	sd	s1,8(sp)
    80000aee:	1000                	addi	s0,sp,32
  struct run *r;

  acquire(&kmem.lock);
    80000af0:	00010497          	auipc	s1,0x10
    80000af4:	06048493          	addi	s1,s1,96 # 80010b50 <kmem>
    80000af8:	8526                	mv	a0,s1
    80000afa:	00000097          	auipc	ra,0x0
    80000afe:	140080e7          	jalr	320(ra) # 80000c3a <acquire>
  r = kmem.freelist;
    80000b02:	6c84                	ld	s1,24(s1)
  if(r)
    80000b04:	c885                	beqz	s1,80000b34 <kalloc+0x4e>
    kmem.freelist = r->next;
    80000b06:	609c                	ld	a5,0(s1)
    80000b08:	00010517          	auipc	a0,0x10
    80000b0c:	04850513          	addi	a0,a0,72 # 80010b50 <kmem>
    80000b10:	ed1c                	sd	a5,24(a0)
  release(&kmem.lock);
    80000b12:	00000097          	auipc	ra,0x0
    80000b16:	1dc080e7          	jalr	476(ra) # 80000cee <release>

  if(r)
    memset((char*)r, 5, PGSIZE); // fill with junk
    80000b1a:	6605                	lui	a2,0x1
    80000b1c:	4595                	li	a1,5
    80000b1e:	8526                	mv	a0,s1
    80000b20:	00000097          	auipc	ra,0x0
    80000b24:	216080e7          	jalr	534(ra) # 80000d36 <memset>
  return (void*)r;
}
    80000b28:	8526                	mv	a0,s1
    80000b2a:	60e2                	ld	ra,24(sp)
    80000b2c:	6442                	ld	s0,16(sp)
    80000b2e:	64a2                	ld	s1,8(sp)
    80000b30:	6105                	addi	sp,sp,32
    80000b32:	8082                	ret
  release(&kmem.lock);
    80000b34:	00010517          	auipc	a0,0x10
    80000b38:	01c50513          	addi	a0,a0,28 # 80010b50 <kmem>
    80000b3c:	00000097          	auipc	ra,0x0
    80000b40:	1b2080e7          	jalr	434(ra) # 80000cee <release>
  if(r)
    80000b44:	b7d5                	j	80000b28 <kalloc+0x42>

0000000080000b46 <kfreepages>:


//to be safe, we need to acquire the kmem.lock while counting so we don't count while another process is modifying the freelist.
int kfreepages()

{
    80000b46:	1101                	addi	sp,sp,-32
    80000b48:	ec06                	sd	ra,24(sp)
    80000b4a:	e822                	sd	s0,16(sp)
    80000b4c:	e426                	sd	s1,8(sp)
    80000b4e:	1000                	addi	s0,sp,32
    int count = 0;
    struct run *r;
    acquire(&kmem.lock);
    80000b50:	00010497          	auipc	s1,0x10
    80000b54:	00048493          	mv	s1,s1
    80000b58:	8526                	mv	a0,s1
    80000b5a:	00000097          	auipc	ra,0x0
    80000b5e:	0e0080e7          	jalr	224(ra) # 80000c3a <acquire>
    r = kmem.freelist;
    80000b62:	6c9c                	ld	a5,24(s1)
    while (r != 0) {
    80000b64:	c39d                	beqz	a5,80000b8a <kfreepages+0x44>
    int count = 0;
    80000b66:	4481                	li	s1,0
        count += 1;
    80000b68:	2485                	addiw	s1,s1,1
        r = r->next;
    80000b6a:	639c                	ld	a5,0(a5)
    while (r != 0) {
    80000b6c:	fff5                	bnez	a5,80000b68 <kfreepages+0x22>
    }

    release(&kmem.lock);
    80000b6e:	00010517          	auipc	a0,0x10
    80000b72:	fe250513          	addi	a0,a0,-30 # 80010b50 <kmem>
    80000b76:	00000097          	auipc	ra,0x0
    80000b7a:	178080e7          	jalr	376(ra) # 80000cee <release>
    return count;
}
    80000b7e:	8526                	mv	a0,s1
    80000b80:	60e2                	ld	ra,24(sp)
    80000b82:	6442                	ld	s0,16(sp)
    80000b84:	64a2                	ld	s1,8(sp)
    80000b86:	6105                	addi	sp,sp,32
    80000b88:	8082                	ret
    int count = 0;
    80000b8a:	4481                	li	s1,0
    80000b8c:	b7cd                	j	80000b6e <kfreepages+0x28>

0000000080000b8e <kfreemem>:


int kfreemem()
{
    80000b8e:	1141                	addi	sp,sp,-16
    80000b90:	e406                	sd	ra,8(sp)
    80000b92:	e022                	sd	s0,0(sp)
    80000b94:	0800                	addi	s0,sp,16

    //return free mem in byte
    int freemem=kfreepages()*4096;
    80000b96:	00000097          	auipc	ra,0x0
    80000b9a:	fb0080e7          	jalr	-80(ra) # 80000b46 <kfreepages>
    return freemem;
}
    80000b9e:	00c5151b          	slliw	a0,a0,0xc
    80000ba2:	60a2                	ld	ra,8(sp)
    80000ba4:	6402                	ld	s0,0(sp)
    80000ba6:	0141                	addi	sp,sp,16
    80000ba8:	8082                	ret

0000000080000baa <initlock>:
#include "proc.h"
#include "defs.h"

void
initlock(struct spinlock *lk, char *name)
{
    80000baa:	1141                	addi	sp,sp,-16
    80000bac:	e422                	sd	s0,8(sp)
    80000bae:	0800                	addi	s0,sp,16
  lk->name = name;
    80000bb0:	e50c                	sd	a1,8(a0)
  lk->locked = 0;
    80000bb2:	00052023          	sw	zero,0(a0)
  lk->cpu = 0;
    80000bb6:	00053823          	sd	zero,16(a0)
}
    80000bba:	6422                	ld	s0,8(sp)
    80000bbc:	0141                	addi	sp,sp,16
    80000bbe:	8082                	ret

0000000080000bc0 <holding>:
// Interrupts must be off.
int
holding(struct spinlock *lk)
{
  int r;
  r = (lk->locked && lk->cpu == mycpu());
    80000bc0:	411c                	lw	a5,0(a0)
    80000bc2:	e399                	bnez	a5,80000bc8 <holding+0x8>
    80000bc4:	4501                	li	a0,0
  return r;
}
    80000bc6:	8082                	ret
{
    80000bc8:	1101                	addi	sp,sp,-32
    80000bca:	ec06                	sd	ra,24(sp)
    80000bcc:	e822                	sd	s0,16(sp)
    80000bce:	e426                	sd	s1,8(sp)
    80000bd0:	1000                	addi	s0,sp,32
  r = (lk->locked && lk->cpu == mycpu());
    80000bd2:	6904                	ld	s1,16(a0)
    80000bd4:	00001097          	auipc	ra,0x1
    80000bd8:	e3a080e7          	jalr	-454(ra) # 80001a0e <mycpu>
    80000bdc:	40a48533          	sub	a0,s1,a0
    80000be0:	00153513          	seqz	a0,a0
}
    80000be4:	60e2                	ld	ra,24(sp)
    80000be6:	6442                	ld	s0,16(sp)
    80000be8:	64a2                	ld	s1,8(sp)
    80000bea:	6105                	addi	sp,sp,32
    80000bec:	8082                	ret

0000000080000bee <push_off>:
// it takes two pop_off()s to undo two push_off()s.  Also, if interrupts
// are initially off, then push_off, pop_off leaves them off.

void
push_off(void)
{
    80000bee:	1101                	addi	sp,sp,-32
    80000bf0:	ec06                	sd	ra,24(sp)
    80000bf2:	e822                	sd	s0,16(sp)
    80000bf4:	e426                	sd	s1,8(sp)
    80000bf6:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80000bf8:	100024f3          	csrr	s1,sstatus
    80000bfc:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    80000c00:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80000c02:	10079073          	csrw	sstatus,a5
  int old = intr_get();

  intr_off();
  if(mycpu()->noff == 0)
    80000c06:	00001097          	auipc	ra,0x1
    80000c0a:	e08080e7          	jalr	-504(ra) # 80001a0e <mycpu>
    80000c0e:	5d3c                	lw	a5,120(a0)
    80000c10:	cf89                	beqz	a5,80000c2a <push_off+0x3c>
    mycpu()->intena = old;
  mycpu()->noff += 1;
    80000c12:	00001097          	auipc	ra,0x1
    80000c16:	dfc080e7          	jalr	-516(ra) # 80001a0e <mycpu>
    80000c1a:	5d3c                	lw	a5,120(a0)
    80000c1c:	2785                	addiw	a5,a5,1
    80000c1e:	dd3c                	sw	a5,120(a0)
}
    80000c20:	60e2                	ld	ra,24(sp)
    80000c22:	6442                	ld	s0,16(sp)
    80000c24:	64a2                	ld	s1,8(sp)
    80000c26:	6105                	addi	sp,sp,32
    80000c28:	8082                	ret
    mycpu()->intena = old;
    80000c2a:	00001097          	auipc	ra,0x1
    80000c2e:	de4080e7          	jalr	-540(ra) # 80001a0e <mycpu>
  return (x & SSTATUS_SIE) != 0;
    80000c32:	8085                	srli	s1,s1,0x1
    80000c34:	8885                	andi	s1,s1,1
    80000c36:	dd64                	sw	s1,124(a0)
    80000c38:	bfe9                	j	80000c12 <push_off+0x24>

0000000080000c3a <acquire>:
{
    80000c3a:	1101                	addi	sp,sp,-32
    80000c3c:	ec06                	sd	ra,24(sp)
    80000c3e:	e822                	sd	s0,16(sp)
    80000c40:	e426                	sd	s1,8(sp)
    80000c42:	1000                	addi	s0,sp,32
    80000c44:	84aa                	mv	s1,a0
  push_off(); // disable interrupts to avoid deadlock.
    80000c46:	00000097          	auipc	ra,0x0
    80000c4a:	fa8080e7          	jalr	-88(ra) # 80000bee <push_off>
  if(holding(lk))
    80000c4e:	8526                	mv	a0,s1
    80000c50:	00000097          	auipc	ra,0x0
    80000c54:	f70080e7          	jalr	-144(ra) # 80000bc0 <holding>
  while(__sync_lock_test_and_set(&lk->locked, 1) != 0)
    80000c58:	4705                	li	a4,1
  if(holding(lk))
    80000c5a:	e115                	bnez	a0,80000c7e <acquire+0x44>
  while(__sync_lock_test_and_set(&lk->locked, 1) != 0)
    80000c5c:	87ba                	mv	a5,a4
    80000c5e:	0cf4a7af          	amoswap.w.aq	a5,a5,(s1)
    80000c62:	2781                	sext.w	a5,a5
    80000c64:	ffe5                	bnez	a5,80000c5c <acquire+0x22>
  __sync_synchronize();
    80000c66:	0ff0000f          	fence
  lk->cpu = mycpu();
    80000c6a:	00001097          	auipc	ra,0x1
    80000c6e:	da4080e7          	jalr	-604(ra) # 80001a0e <mycpu>
    80000c72:	e888                	sd	a0,16(s1)
}
    80000c74:	60e2                	ld	ra,24(sp)
    80000c76:	6442                	ld	s0,16(sp)
    80000c78:	64a2                	ld	s1,8(sp)
    80000c7a:	6105                	addi	sp,sp,32
    80000c7c:	8082                	ret
    panic("acquire");
    80000c7e:	00007517          	auipc	a0,0x7
    80000c82:	3f250513          	addi	a0,a0,1010 # 80008070 <digits+0x30>
    80000c86:	00000097          	auipc	ra,0x0
    80000c8a:	8b8080e7          	jalr	-1864(ra) # 8000053e <panic>

0000000080000c8e <pop_off>:

void
pop_off(void)
{
    80000c8e:	1141                	addi	sp,sp,-16
    80000c90:	e406                	sd	ra,8(sp)
    80000c92:	e022                	sd	s0,0(sp)
    80000c94:	0800                	addi	s0,sp,16
  struct cpu *c = mycpu();
    80000c96:	00001097          	auipc	ra,0x1
    80000c9a:	d78080e7          	jalr	-648(ra) # 80001a0e <mycpu>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80000c9e:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80000ca2:	8b89                	andi	a5,a5,2
  if(intr_get())
    80000ca4:	e78d                	bnez	a5,80000cce <pop_off+0x40>
    panic("pop_off - interruptible");
  if(c->noff < 1)
    80000ca6:	5d3c                	lw	a5,120(a0)
    80000ca8:	02f05b63          	blez	a5,80000cde <pop_off+0x50>
    panic("pop_off");
  c->noff -= 1;
    80000cac:	37fd                	addiw	a5,a5,-1
    80000cae:	0007871b          	sext.w	a4,a5
    80000cb2:	dd3c                	sw	a5,120(a0)
  if(c->noff == 0 && c->intena)
    80000cb4:	eb09                	bnez	a4,80000cc6 <pop_off+0x38>
    80000cb6:	5d7c                	lw	a5,124(a0)
    80000cb8:	c799                	beqz	a5,80000cc6 <pop_off+0x38>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80000cba:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80000cbe:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80000cc2:	10079073          	csrw	sstatus,a5
    intr_on();
}
    80000cc6:	60a2                	ld	ra,8(sp)
    80000cc8:	6402                	ld	s0,0(sp)
    80000cca:	0141                	addi	sp,sp,16
    80000ccc:	8082                	ret
    panic("pop_off - interruptible");
    80000cce:	00007517          	auipc	a0,0x7
    80000cd2:	3aa50513          	addi	a0,a0,938 # 80008078 <digits+0x38>
    80000cd6:	00000097          	auipc	ra,0x0
    80000cda:	868080e7          	jalr	-1944(ra) # 8000053e <panic>
    panic("pop_off");
    80000cde:	00007517          	auipc	a0,0x7
    80000ce2:	3b250513          	addi	a0,a0,946 # 80008090 <digits+0x50>
    80000ce6:	00000097          	auipc	ra,0x0
    80000cea:	858080e7          	jalr	-1960(ra) # 8000053e <panic>

0000000080000cee <release>:
{
    80000cee:	1101                	addi	sp,sp,-32
    80000cf0:	ec06                	sd	ra,24(sp)
    80000cf2:	e822                	sd	s0,16(sp)
    80000cf4:	e426                	sd	s1,8(sp)
    80000cf6:	1000                	addi	s0,sp,32
    80000cf8:	84aa                	mv	s1,a0
  if(!holding(lk))
    80000cfa:	00000097          	auipc	ra,0x0
    80000cfe:	ec6080e7          	jalr	-314(ra) # 80000bc0 <holding>
    80000d02:	c115                	beqz	a0,80000d26 <release+0x38>
  lk->cpu = 0;
    80000d04:	0004b823          	sd	zero,16(s1) # 80010b60 <kmem+0x10>
  __sync_synchronize();
    80000d08:	0ff0000f          	fence
  __sync_lock_release(&lk->locked);
    80000d0c:	0f50000f          	fence	iorw,ow
    80000d10:	0804a02f          	amoswap.w	zero,zero,(s1)
  pop_off();
    80000d14:	00000097          	auipc	ra,0x0
    80000d18:	f7a080e7          	jalr	-134(ra) # 80000c8e <pop_off>
}
    80000d1c:	60e2                	ld	ra,24(sp)
    80000d1e:	6442                	ld	s0,16(sp)
    80000d20:	64a2                	ld	s1,8(sp)
    80000d22:	6105                	addi	sp,sp,32
    80000d24:	8082                	ret
    panic("release");
    80000d26:	00007517          	auipc	a0,0x7
    80000d2a:	37250513          	addi	a0,a0,882 # 80008098 <digits+0x58>
    80000d2e:	00000097          	auipc	ra,0x0
    80000d32:	810080e7          	jalr	-2032(ra) # 8000053e <panic>

0000000080000d36 <memset>:
#include "types.h"

void*
memset(void *dst, int c, uint n)
{
    80000d36:	1141                	addi	sp,sp,-16
    80000d38:	e422                	sd	s0,8(sp)
    80000d3a:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
    80000d3c:	ca19                	beqz	a2,80000d52 <memset+0x1c>
    80000d3e:	87aa                	mv	a5,a0
    80000d40:	1602                	slli	a2,a2,0x20
    80000d42:	9201                	srli	a2,a2,0x20
    80000d44:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
    80000d48:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
    80000d4c:	0785                	addi	a5,a5,1
    80000d4e:	fee79de3          	bne	a5,a4,80000d48 <memset+0x12>
  }
  return dst;
}
    80000d52:	6422                	ld	s0,8(sp)
    80000d54:	0141                	addi	sp,sp,16
    80000d56:	8082                	ret

0000000080000d58 <memcmp>:

int
memcmp(const void *v1, const void *v2, uint n)
{
    80000d58:	1141                	addi	sp,sp,-16
    80000d5a:	e422                	sd	s0,8(sp)
    80000d5c:	0800                	addi	s0,sp,16
  const uchar *s1, *s2;

  s1 = v1;
  s2 = v2;
  while(n-- > 0){
    80000d5e:	ca05                	beqz	a2,80000d8e <memcmp+0x36>
    80000d60:	fff6069b          	addiw	a3,a2,-1
    80000d64:	1682                	slli	a3,a3,0x20
    80000d66:	9281                	srli	a3,a3,0x20
    80000d68:	0685                	addi	a3,a3,1
    80000d6a:	96aa                	add	a3,a3,a0
    if(*s1 != *s2)
    80000d6c:	00054783          	lbu	a5,0(a0)
    80000d70:	0005c703          	lbu	a4,0(a1)
    80000d74:	00e79863          	bne	a5,a4,80000d84 <memcmp+0x2c>
      return *s1 - *s2;
    s1++, s2++;
    80000d78:	0505                	addi	a0,a0,1
    80000d7a:	0585                	addi	a1,a1,1
  while(n-- > 0){
    80000d7c:	fed518e3          	bne	a0,a3,80000d6c <memcmp+0x14>
  }

  return 0;
    80000d80:	4501                	li	a0,0
    80000d82:	a019                	j	80000d88 <memcmp+0x30>
      return *s1 - *s2;
    80000d84:	40e7853b          	subw	a0,a5,a4
}
    80000d88:	6422                	ld	s0,8(sp)
    80000d8a:	0141                	addi	sp,sp,16
    80000d8c:	8082                	ret
  return 0;
    80000d8e:	4501                	li	a0,0
    80000d90:	bfe5                	j	80000d88 <memcmp+0x30>

0000000080000d92 <memmove>:

void*
memmove(void *dst, const void *src, uint n)
{
    80000d92:	1141                	addi	sp,sp,-16
    80000d94:	e422                	sd	s0,8(sp)
    80000d96:	0800                	addi	s0,sp,16
  const char *s;
  char *d;

  if(n == 0)
    80000d98:	c205                	beqz	a2,80000db8 <memmove+0x26>
    return dst;
  
  s = src;
  d = dst;
  if(s < d && s + n > d){
    80000d9a:	02a5e263          	bltu	a1,a0,80000dbe <memmove+0x2c>
    s += n;
    d += n;
    while(n-- > 0)
      *--d = *--s;
  } else
    while(n-- > 0)
    80000d9e:	1602                	slli	a2,a2,0x20
    80000da0:	9201                	srli	a2,a2,0x20
    80000da2:	00c587b3          	add	a5,a1,a2
{
    80000da6:	872a                	mv	a4,a0
      *d++ = *s++;
    80000da8:	0585                	addi	a1,a1,1
    80000daa:	0705                	addi	a4,a4,1
    80000dac:	fff5c683          	lbu	a3,-1(a1)
    80000db0:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
    80000db4:	fef59ae3          	bne	a1,a5,80000da8 <memmove+0x16>

  return dst;
}
    80000db8:	6422                	ld	s0,8(sp)
    80000dba:	0141                	addi	sp,sp,16
    80000dbc:	8082                	ret
  if(s < d && s + n > d){
    80000dbe:	02061693          	slli	a3,a2,0x20
    80000dc2:	9281                	srli	a3,a3,0x20
    80000dc4:	00d58733          	add	a4,a1,a3
    80000dc8:	fce57be3          	bgeu	a0,a4,80000d9e <memmove+0xc>
    d += n;
    80000dcc:	96aa                	add	a3,a3,a0
    while(n-- > 0)
    80000dce:	fff6079b          	addiw	a5,a2,-1
    80000dd2:	1782                	slli	a5,a5,0x20
    80000dd4:	9381                	srli	a5,a5,0x20
    80000dd6:	fff7c793          	not	a5,a5
    80000dda:	97ba                	add	a5,a5,a4
      *--d = *--s;
    80000ddc:	177d                	addi	a4,a4,-1
    80000dde:	16fd                	addi	a3,a3,-1
    80000de0:	00074603          	lbu	a2,0(a4)
    80000de4:	00c68023          	sb	a2,0(a3)
    while(n-- > 0)
    80000de8:	fee79ae3          	bne	a5,a4,80000ddc <memmove+0x4a>
    80000dec:	b7f1                	j	80000db8 <memmove+0x26>

0000000080000dee <memcpy>:

// memcpy exists to placate GCC.  Use memmove.
void*
memcpy(void *dst, const void *src, uint n)
{
    80000dee:	1141                	addi	sp,sp,-16
    80000df0:	e406                	sd	ra,8(sp)
    80000df2:	e022                	sd	s0,0(sp)
    80000df4:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
    80000df6:	00000097          	auipc	ra,0x0
    80000dfa:	f9c080e7          	jalr	-100(ra) # 80000d92 <memmove>
}
    80000dfe:	60a2                	ld	ra,8(sp)
    80000e00:	6402                	ld	s0,0(sp)
    80000e02:	0141                	addi	sp,sp,16
    80000e04:	8082                	ret

0000000080000e06 <strncmp>:

int
strncmp(const char *p, const char *q, uint n)
{
    80000e06:	1141                	addi	sp,sp,-16
    80000e08:	e422                	sd	s0,8(sp)
    80000e0a:	0800                	addi	s0,sp,16
  while(n > 0 && *p && *p == *q)
    80000e0c:	ce11                	beqz	a2,80000e28 <strncmp+0x22>
    80000e0e:	00054783          	lbu	a5,0(a0)
    80000e12:	cf89                	beqz	a5,80000e2c <strncmp+0x26>
    80000e14:	0005c703          	lbu	a4,0(a1)
    80000e18:	00f71a63          	bne	a4,a5,80000e2c <strncmp+0x26>
    n--, p++, q++;
    80000e1c:	367d                	addiw	a2,a2,-1
    80000e1e:	0505                	addi	a0,a0,1
    80000e20:	0585                	addi	a1,a1,1
  while(n > 0 && *p && *p == *q)
    80000e22:	f675                	bnez	a2,80000e0e <strncmp+0x8>
  if(n == 0)
    return 0;
    80000e24:	4501                	li	a0,0
    80000e26:	a809                	j	80000e38 <strncmp+0x32>
    80000e28:	4501                	li	a0,0
    80000e2a:	a039                	j	80000e38 <strncmp+0x32>
  if(n == 0)
    80000e2c:	ca09                	beqz	a2,80000e3e <strncmp+0x38>
  return (uchar)*p - (uchar)*q;
    80000e2e:	00054503          	lbu	a0,0(a0)
    80000e32:	0005c783          	lbu	a5,0(a1)
    80000e36:	9d1d                	subw	a0,a0,a5
}
    80000e38:	6422                	ld	s0,8(sp)
    80000e3a:	0141                	addi	sp,sp,16
    80000e3c:	8082                	ret
    return 0;
    80000e3e:	4501                	li	a0,0
    80000e40:	bfe5                	j	80000e38 <strncmp+0x32>

0000000080000e42 <strncpy>:

char*
strncpy(char *s, const char *t, int n)
{
    80000e42:	1141                	addi	sp,sp,-16
    80000e44:	e422                	sd	s0,8(sp)
    80000e46:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while(n-- > 0 && (*s++ = *t++) != 0)
    80000e48:	872a                	mv	a4,a0
    80000e4a:	8832                	mv	a6,a2
    80000e4c:	367d                	addiw	a2,a2,-1
    80000e4e:	01005963          	blez	a6,80000e60 <strncpy+0x1e>
    80000e52:	0705                	addi	a4,a4,1
    80000e54:	0005c783          	lbu	a5,0(a1)
    80000e58:	fef70fa3          	sb	a5,-1(a4)
    80000e5c:	0585                	addi	a1,a1,1
    80000e5e:	f7f5                	bnez	a5,80000e4a <strncpy+0x8>
    ;
  while(n-- > 0)
    80000e60:	86ba                	mv	a3,a4
    80000e62:	00c05c63          	blez	a2,80000e7a <strncpy+0x38>
    *s++ = 0;
    80000e66:	0685                	addi	a3,a3,1
    80000e68:	fe068fa3          	sb	zero,-1(a3)
  while(n-- > 0)
    80000e6c:	fff6c793          	not	a5,a3
    80000e70:	9fb9                	addw	a5,a5,a4
    80000e72:	010787bb          	addw	a5,a5,a6
    80000e76:	fef048e3          	bgtz	a5,80000e66 <strncpy+0x24>
  return os;
}
    80000e7a:	6422                	ld	s0,8(sp)
    80000e7c:	0141                	addi	sp,sp,16
    80000e7e:	8082                	ret

0000000080000e80 <safestrcpy>:

// Like strncpy but guaranteed to NUL-terminate.
char*
safestrcpy(char *s, const char *t, int n)
{
    80000e80:	1141                	addi	sp,sp,-16
    80000e82:	e422                	sd	s0,8(sp)
    80000e84:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  if(n <= 0)
    80000e86:	02c05363          	blez	a2,80000eac <safestrcpy+0x2c>
    80000e8a:	fff6069b          	addiw	a3,a2,-1
    80000e8e:	1682                	slli	a3,a3,0x20
    80000e90:	9281                	srli	a3,a3,0x20
    80000e92:	96ae                	add	a3,a3,a1
    80000e94:	87aa                	mv	a5,a0
    return os;
  while(--n > 0 && (*s++ = *t++) != 0)
    80000e96:	00d58963          	beq	a1,a3,80000ea8 <safestrcpy+0x28>
    80000e9a:	0585                	addi	a1,a1,1
    80000e9c:	0785                	addi	a5,a5,1
    80000e9e:	fff5c703          	lbu	a4,-1(a1)
    80000ea2:	fee78fa3          	sb	a4,-1(a5)
    80000ea6:	fb65                	bnez	a4,80000e96 <safestrcpy+0x16>
    ;
  *s = 0;
    80000ea8:	00078023          	sb	zero,0(a5)
  return os;
}
    80000eac:	6422                	ld	s0,8(sp)
    80000eae:	0141                	addi	sp,sp,16
    80000eb0:	8082                	ret

0000000080000eb2 <strlen>:

int
strlen(const char *s)
{
    80000eb2:	1141                	addi	sp,sp,-16
    80000eb4:	e422                	sd	s0,8(sp)
    80000eb6:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
    80000eb8:	00054783          	lbu	a5,0(a0)
    80000ebc:	cf91                	beqz	a5,80000ed8 <strlen+0x26>
    80000ebe:	0505                	addi	a0,a0,1
    80000ec0:	87aa                	mv	a5,a0
    80000ec2:	4685                	li	a3,1
    80000ec4:	9e89                	subw	a3,a3,a0
    80000ec6:	00f6853b          	addw	a0,a3,a5
    80000eca:	0785                	addi	a5,a5,1
    80000ecc:	fff7c703          	lbu	a4,-1(a5)
    80000ed0:	fb7d                	bnez	a4,80000ec6 <strlen+0x14>
    ;
  return n;
}
    80000ed2:	6422                	ld	s0,8(sp)
    80000ed4:	0141                	addi	sp,sp,16
    80000ed6:	8082                	ret
  for(n = 0; s[n]; n++)
    80000ed8:	4501                	li	a0,0
    80000eda:	bfe5                	j	80000ed2 <strlen+0x20>

0000000080000edc <main>:
volatile static int started = 0;

// start() jumps here in supervisor mode on all CPUs.
void
main()
{
    80000edc:	1141                	addi	sp,sp,-16
    80000ede:	e406                	sd	ra,8(sp)
    80000ee0:	e022                	sd	s0,0(sp)
    80000ee2:	0800                	addi	s0,sp,16
  if(cpuid() == 0){
    80000ee4:	00001097          	auipc	ra,0x1
    80000ee8:	b1a080e7          	jalr	-1254(ra) # 800019fe <cpuid>
    virtio_disk_init(); // emulated hard disk
    userinit();      // first user process
    __sync_synchronize();
    started = 1;
  } else {
    while(started == 0)
    80000eec:	00008717          	auipc	a4,0x8
    80000ef0:	9fc70713          	addi	a4,a4,-1540 # 800088e8 <started>
  if(cpuid() == 0){
    80000ef4:	c139                	beqz	a0,80000f3a <main+0x5e>
    while(started == 0)
    80000ef6:	431c                	lw	a5,0(a4)
    80000ef8:	2781                	sext.w	a5,a5
    80000efa:	dff5                	beqz	a5,80000ef6 <main+0x1a>
      ;
    __sync_synchronize();
    80000efc:	0ff0000f          	fence
    printf("hart %d starting\n", cpuid());
    80000f00:	00001097          	auipc	ra,0x1
    80000f04:	afe080e7          	jalr	-1282(ra) # 800019fe <cpuid>
    80000f08:	85aa                	mv	a1,a0
    80000f0a:	00007517          	auipc	a0,0x7
    80000f0e:	1e650513          	addi	a0,a0,486 # 800080f0 <digits+0xb0>
    80000f12:	fffff097          	auipc	ra,0xfffff
    80000f16:	676080e7          	jalr	1654(ra) # 80000588 <printf>
    kvminithart();    // turn on paging
    80000f1a:	00000097          	auipc	ra,0x0
    80000f1e:	0f2080e7          	jalr	242(ra) # 8000100c <kvminithart>
    trapinithart();   // install kernel trap vector
    80000f22:	00001097          	auipc	ra,0x1
    80000f26:	7a4080e7          	jalr	1956(ra) # 800026c6 <trapinithart>
    plicinithart();   // ask PLIC for device interrupts
    80000f2a:	00005097          	auipc	ra,0x5
    80000f2e:	d46080e7          	jalr	-698(ra) # 80005c70 <plicinithart>
  }

  scheduler();        
    80000f32:	00001097          	auipc	ra,0x1
    80000f36:	fee080e7          	jalr	-18(ra) # 80001f20 <scheduler>
    consoleinit();
    80000f3a:	fffff097          	auipc	ra,0xfffff
    80000f3e:	516080e7          	jalr	1302(ra) # 80000450 <consoleinit>
    printfinit();
    80000f42:	00000097          	auipc	ra,0x0
    80000f46:	826080e7          	jalr	-2010(ra) # 80000768 <printfinit>
    printf("\n");
    80000f4a:	00007517          	auipc	a0,0x7
    80000f4e:	1b650513          	addi	a0,a0,438 # 80008100 <digits+0xc0>
    80000f52:	fffff097          	auipc	ra,0xfffff
    80000f56:	636080e7          	jalr	1590(ra) # 80000588 <printf>
    printf("xv6 kernel is booting\n");
    80000f5a:	00007517          	auipc	a0,0x7
    80000f5e:	14650513          	addi	a0,a0,326 # 800080a0 <digits+0x60>
    80000f62:	fffff097          	auipc	ra,0xfffff
    80000f66:	626080e7          	jalr	1574(ra) # 80000588 <printf>
    printf("\n");
    80000f6a:	00007517          	auipc	a0,0x7
    80000f6e:	19650513          	addi	a0,a0,406 # 80008100 <digits+0xc0>
    80000f72:	fffff097          	auipc	ra,0xfffff
    80000f76:	616080e7          	jalr	1558(ra) # 80000588 <printf>
    kinit();         // physical page allocator
    80000f7a:	00000097          	auipc	ra,0x0
    80000f7e:	b30080e7          	jalr	-1232(ra) # 80000aaa <kinit>
    printf("xv6 free memory before user processes start: %d byte.\n", kfreemem());
    80000f82:	00000097          	auipc	ra,0x0
    80000f86:	c0c080e7          	jalr	-1012(ra) # 80000b8e <kfreemem>
    80000f8a:	85aa                	mv	a1,a0
    80000f8c:	00007517          	auipc	a0,0x7
    80000f90:	12c50513          	addi	a0,a0,300 # 800080b8 <digits+0x78>
    80000f94:	fffff097          	auipc	ra,0xfffff
    80000f98:	5f4080e7          	jalr	1524(ra) # 80000588 <printf>
    kvminit();       // create kernel page table
    80000f9c:	00000097          	auipc	ra,0x0
    80000fa0:	326080e7          	jalr	806(ra) # 800012c2 <kvminit>
    kvminithart();   // turn on paging
    80000fa4:	00000097          	auipc	ra,0x0
    80000fa8:	068080e7          	jalr	104(ra) # 8000100c <kvminithart>
    procinit();      // process table
    80000fac:	00001097          	auipc	ra,0x1
    80000fb0:	99e080e7          	jalr	-1634(ra) # 8000194a <procinit>
    trapinit();      // trap vectors
    80000fb4:	00001097          	auipc	ra,0x1
    80000fb8:	6ea080e7          	jalr	1770(ra) # 8000269e <trapinit>
    trapinithart();  // install kernel trap vector
    80000fbc:	00001097          	auipc	ra,0x1
    80000fc0:	70a080e7          	jalr	1802(ra) # 800026c6 <trapinithart>
    plicinit();      // set up interrupt controller
    80000fc4:	00005097          	auipc	ra,0x5
    80000fc8:	c96080e7          	jalr	-874(ra) # 80005c5a <plicinit>
    plicinithart();  // ask PLIC for device interrupts
    80000fcc:	00005097          	auipc	ra,0x5
    80000fd0:	ca4080e7          	jalr	-860(ra) # 80005c70 <plicinithart>
    binit();         // buffer cache
    80000fd4:	00002097          	auipc	ra,0x2
    80000fd8:	e46080e7          	jalr	-442(ra) # 80002e1a <binit>
    iinit();         // inode table
    80000fdc:	00002097          	auipc	ra,0x2
    80000fe0:	4ea080e7          	jalr	1258(ra) # 800034c6 <iinit>
    fileinit();      // file table
    80000fe4:	00003097          	auipc	ra,0x3
    80000fe8:	488080e7          	jalr	1160(ra) # 8000446c <fileinit>
    virtio_disk_init(); // emulated hard disk
    80000fec:	00005097          	auipc	ra,0x5
    80000ff0:	d8c080e7          	jalr	-628(ra) # 80005d78 <virtio_disk_init>
    userinit();      // first user process
    80000ff4:	00001097          	auipc	ra,0x1
    80000ff8:	d0e080e7          	jalr	-754(ra) # 80001d02 <userinit>
    __sync_synchronize();
    80000ffc:	0ff0000f          	fence
    started = 1;
    80001000:	4785                	li	a5,1
    80001002:	00008717          	auipc	a4,0x8
    80001006:	8ef72323          	sw	a5,-1818(a4) # 800088e8 <started>
    8000100a:	b725                	j	80000f32 <main+0x56>

000000008000100c <kvminithart>:

// Switch h/w page table register to the kernel's page table,
// and enable paging.
void
kvminithart()
{
    8000100c:	1141                	addi	sp,sp,-16
    8000100e:	e422                	sd	s0,8(sp)
    80001010:	0800                	addi	s0,sp,16
// flush the TLB.
static inline void
sfence_vma()
{
  // the zero, zero means flush all TLB entries.
  asm volatile("sfence.vma zero, zero");
    80001012:	12000073          	sfence.vma
  // wait for any previous writes to the page table memory to finish.
  sfence_vma();

  w_satp(MAKE_SATP(kernel_pagetable));
    80001016:	00008797          	auipc	a5,0x8
    8000101a:	8da7b783          	ld	a5,-1830(a5) # 800088f0 <kernel_pagetable>
    8000101e:	83b1                	srli	a5,a5,0xc
    80001020:	577d                	li	a4,-1
    80001022:	177e                	slli	a4,a4,0x3f
    80001024:	8fd9                	or	a5,a5,a4
  asm volatile("csrw satp, %0" : : "r" (x));
    80001026:	18079073          	csrw	satp,a5
  asm volatile("sfence.vma zero, zero");
    8000102a:	12000073          	sfence.vma

  // flush stale entries from the TLB.
  sfence_vma();
}
    8000102e:	6422                	ld	s0,8(sp)
    80001030:	0141                	addi	sp,sp,16
    80001032:	8082                	ret

0000000080001034 <walk>:
//   21..29 -- 9 bits of level-1 index.
//   12..20 -- 9 bits of level-0 index.
//    0..11 -- 12 bits of byte offset within the page.
pte_t *
walk(pagetable_t pagetable, uint64 va, int alloc)
{
    80001034:	7139                	addi	sp,sp,-64
    80001036:	fc06                	sd	ra,56(sp)
    80001038:	f822                	sd	s0,48(sp)
    8000103a:	f426                	sd	s1,40(sp)
    8000103c:	f04a                	sd	s2,32(sp)
    8000103e:	ec4e                	sd	s3,24(sp)
    80001040:	e852                	sd	s4,16(sp)
    80001042:	e456                	sd	s5,8(sp)
    80001044:	e05a                	sd	s6,0(sp)
    80001046:	0080                	addi	s0,sp,64
    80001048:	84aa                	mv	s1,a0
    8000104a:	89ae                	mv	s3,a1
    8000104c:	8ab2                	mv	s5,a2
  if(va >= MAXVA)
    8000104e:	57fd                	li	a5,-1
    80001050:	83e9                	srli	a5,a5,0x1a
    80001052:	4a79                	li	s4,30
    panic("walk");

  for(int level = 2; level > 0; level--) {
    80001054:	4b31                	li	s6,12
  if(va >= MAXVA)
    80001056:	04b7f263          	bgeu	a5,a1,8000109a <walk+0x66>
    panic("walk");
    8000105a:	00007517          	auipc	a0,0x7
    8000105e:	0ae50513          	addi	a0,a0,174 # 80008108 <digits+0xc8>
    80001062:	fffff097          	auipc	ra,0xfffff
    80001066:	4dc080e7          	jalr	1244(ra) # 8000053e <panic>
    pte_t *pte = &pagetable[PX(level, va)];
    if(*pte & PTE_V) {
      pagetable = (pagetable_t)PTE2PA(*pte);
    } else {
      if(!alloc || (pagetable = (pde_t*)kalloc()) == 0)
    8000106a:	060a8663          	beqz	s5,800010d6 <walk+0xa2>
    8000106e:	00000097          	auipc	ra,0x0
    80001072:	a78080e7          	jalr	-1416(ra) # 80000ae6 <kalloc>
    80001076:	84aa                	mv	s1,a0
    80001078:	c529                	beqz	a0,800010c2 <walk+0x8e>
        return 0;
      memset(pagetable, 0, PGSIZE);
    8000107a:	6605                	lui	a2,0x1
    8000107c:	4581                	li	a1,0
    8000107e:	00000097          	auipc	ra,0x0
    80001082:	cb8080e7          	jalr	-840(ra) # 80000d36 <memset>
      *pte = PA2PTE(pagetable) | PTE_V;
    80001086:	00c4d793          	srli	a5,s1,0xc
    8000108a:	07aa                	slli	a5,a5,0xa
    8000108c:	0017e793          	ori	a5,a5,1
    80001090:	00f93023          	sd	a5,0(s2)
  for(int level = 2; level > 0; level--) {
    80001094:	3a5d                	addiw	s4,s4,-9
    80001096:	036a0063          	beq	s4,s6,800010b6 <walk+0x82>
    pte_t *pte = &pagetable[PX(level, va)];
    8000109a:	0149d933          	srl	s2,s3,s4
    8000109e:	1ff97913          	andi	s2,s2,511
    800010a2:	090e                	slli	s2,s2,0x3
    800010a4:	9926                	add	s2,s2,s1
    if(*pte & PTE_V) {
    800010a6:	00093483          	ld	s1,0(s2)
    800010aa:	0014f793          	andi	a5,s1,1
    800010ae:	dfd5                	beqz	a5,8000106a <walk+0x36>
      pagetable = (pagetable_t)PTE2PA(*pte);
    800010b0:	80a9                	srli	s1,s1,0xa
    800010b2:	04b2                	slli	s1,s1,0xc
    800010b4:	b7c5                	j	80001094 <walk+0x60>
    }
  }
  return &pagetable[PX(0, va)];
    800010b6:	00c9d513          	srli	a0,s3,0xc
    800010ba:	1ff57513          	andi	a0,a0,511
    800010be:	050e                	slli	a0,a0,0x3
    800010c0:	9526                	add	a0,a0,s1
}
    800010c2:	70e2                	ld	ra,56(sp)
    800010c4:	7442                	ld	s0,48(sp)
    800010c6:	74a2                	ld	s1,40(sp)
    800010c8:	7902                	ld	s2,32(sp)
    800010ca:	69e2                	ld	s3,24(sp)
    800010cc:	6a42                	ld	s4,16(sp)
    800010ce:	6aa2                	ld	s5,8(sp)
    800010d0:	6b02                	ld	s6,0(sp)
    800010d2:	6121                	addi	sp,sp,64
    800010d4:	8082                	ret
        return 0;
    800010d6:	4501                	li	a0,0
    800010d8:	b7ed                	j	800010c2 <walk+0x8e>

00000000800010da <walkaddr>:
walkaddr(pagetable_t pagetable, uint64 va)
{
  pte_t *pte;
  uint64 pa;

  if(va >= MAXVA)
    800010da:	57fd                	li	a5,-1
    800010dc:	83e9                	srli	a5,a5,0x1a
    800010de:	00b7f463          	bgeu	a5,a1,800010e6 <walkaddr+0xc>
    return 0;
    800010e2:	4501                	li	a0,0
    return 0;
  if((*pte & PTE_U) == 0)
    return 0;
  pa = PTE2PA(*pte);
  return pa;
}
    800010e4:	8082                	ret
{
    800010e6:	1141                	addi	sp,sp,-16
    800010e8:	e406                	sd	ra,8(sp)
    800010ea:	e022                	sd	s0,0(sp)
    800010ec:	0800                	addi	s0,sp,16
  pte = walk(pagetable, va, 0);
    800010ee:	4601                	li	a2,0
    800010f0:	00000097          	auipc	ra,0x0
    800010f4:	f44080e7          	jalr	-188(ra) # 80001034 <walk>
  if(pte == 0)
    800010f8:	c105                	beqz	a0,80001118 <walkaddr+0x3e>
  if((*pte & PTE_V) == 0)
    800010fa:	611c                	ld	a5,0(a0)
  if((*pte & PTE_U) == 0)
    800010fc:	0117f693          	andi	a3,a5,17
    80001100:	4745                	li	a4,17
    return 0;
    80001102:	4501                	li	a0,0
  if((*pte & PTE_U) == 0)
    80001104:	00e68663          	beq	a3,a4,80001110 <walkaddr+0x36>
}
    80001108:	60a2                	ld	ra,8(sp)
    8000110a:	6402                	ld	s0,0(sp)
    8000110c:	0141                	addi	sp,sp,16
    8000110e:	8082                	ret
  pa = PTE2PA(*pte);
    80001110:	00a7d513          	srli	a0,a5,0xa
    80001114:	0532                	slli	a0,a0,0xc
  return pa;
    80001116:	bfcd                	j	80001108 <walkaddr+0x2e>
    return 0;
    80001118:	4501                	li	a0,0
    8000111a:	b7fd                	j	80001108 <walkaddr+0x2e>

000000008000111c <mappages>:
// physical addresses starting at pa. va and size might not
// be page-aligned. Returns 0 on success, -1 if walk() couldn't
// allocate a needed page-table page.
int
mappages(pagetable_t pagetable, uint64 va, uint64 size, uint64 pa, int perm)
{
    8000111c:	715d                	addi	sp,sp,-80
    8000111e:	e486                	sd	ra,72(sp)
    80001120:	e0a2                	sd	s0,64(sp)
    80001122:	fc26                	sd	s1,56(sp)
    80001124:	f84a                	sd	s2,48(sp)
    80001126:	f44e                	sd	s3,40(sp)
    80001128:	f052                	sd	s4,32(sp)
    8000112a:	ec56                	sd	s5,24(sp)
    8000112c:	e85a                	sd	s6,16(sp)
    8000112e:	e45e                	sd	s7,8(sp)
    80001130:	0880                	addi	s0,sp,80
  uint64 a, last;
  pte_t *pte;

  if(size == 0)
    80001132:	c639                	beqz	a2,80001180 <mappages+0x64>
    80001134:	8aaa                	mv	s5,a0
    80001136:	8b3a                	mv	s6,a4
    panic("mappages: size");
  
  a = PGROUNDDOWN(va);
    80001138:	77fd                	lui	a5,0xfffff
    8000113a:	00f5fa33          	and	s4,a1,a5
  last = PGROUNDDOWN(va + size - 1);
    8000113e:	15fd                	addi	a1,a1,-1
    80001140:	00c589b3          	add	s3,a1,a2
    80001144:	00f9f9b3          	and	s3,s3,a5
  a = PGROUNDDOWN(va);
    80001148:	8952                	mv	s2,s4
    8000114a:	41468a33          	sub	s4,a3,s4
    if(*pte & PTE_V)
      panic("mappages: remap");
    *pte = PA2PTE(pa) | perm | PTE_V;
    if(a == last)
      break;
    a += PGSIZE;
    8000114e:	6b85                	lui	s7,0x1
    80001150:	012a04b3          	add	s1,s4,s2
    if((pte = walk(pagetable, a, 1)) == 0)
    80001154:	4605                	li	a2,1
    80001156:	85ca                	mv	a1,s2
    80001158:	8556                	mv	a0,s5
    8000115a:	00000097          	auipc	ra,0x0
    8000115e:	eda080e7          	jalr	-294(ra) # 80001034 <walk>
    80001162:	cd1d                	beqz	a0,800011a0 <mappages+0x84>
    if(*pte & PTE_V)
    80001164:	611c                	ld	a5,0(a0)
    80001166:	8b85                	andi	a5,a5,1
    80001168:	e785                	bnez	a5,80001190 <mappages+0x74>
    *pte = PA2PTE(pa) | perm | PTE_V;
    8000116a:	80b1                	srli	s1,s1,0xc
    8000116c:	04aa                	slli	s1,s1,0xa
    8000116e:	0164e4b3          	or	s1,s1,s6
    80001172:	0014e493          	ori	s1,s1,1
    80001176:	e104                	sd	s1,0(a0)
    if(a == last)
    80001178:	05390063          	beq	s2,s3,800011b8 <mappages+0x9c>
    a += PGSIZE;
    8000117c:	995e                	add	s2,s2,s7
    if((pte = walk(pagetable, a, 1)) == 0)
    8000117e:	bfc9                	j	80001150 <mappages+0x34>
    panic("mappages: size");
    80001180:	00007517          	auipc	a0,0x7
    80001184:	f9050513          	addi	a0,a0,-112 # 80008110 <digits+0xd0>
    80001188:	fffff097          	auipc	ra,0xfffff
    8000118c:	3b6080e7          	jalr	950(ra) # 8000053e <panic>
      panic("mappages: remap");
    80001190:	00007517          	auipc	a0,0x7
    80001194:	f9050513          	addi	a0,a0,-112 # 80008120 <digits+0xe0>
    80001198:	fffff097          	auipc	ra,0xfffff
    8000119c:	3a6080e7          	jalr	934(ra) # 8000053e <panic>
      return -1;
    800011a0:	557d                	li	a0,-1
    pa += PGSIZE;
  }
  return 0;
}
    800011a2:	60a6                	ld	ra,72(sp)
    800011a4:	6406                	ld	s0,64(sp)
    800011a6:	74e2                	ld	s1,56(sp)
    800011a8:	7942                	ld	s2,48(sp)
    800011aa:	79a2                	ld	s3,40(sp)
    800011ac:	7a02                	ld	s4,32(sp)
    800011ae:	6ae2                	ld	s5,24(sp)
    800011b0:	6b42                	ld	s6,16(sp)
    800011b2:	6ba2                	ld	s7,8(sp)
    800011b4:	6161                	addi	sp,sp,80
    800011b6:	8082                	ret
  return 0;
    800011b8:	4501                	li	a0,0
    800011ba:	b7e5                	j	800011a2 <mappages+0x86>

00000000800011bc <kvmmap>:
{
    800011bc:	1141                	addi	sp,sp,-16
    800011be:	e406                	sd	ra,8(sp)
    800011c0:	e022                	sd	s0,0(sp)
    800011c2:	0800                	addi	s0,sp,16
    800011c4:	87b6                	mv	a5,a3
  if(mappages(kpgtbl, va, sz, pa, perm) != 0)
    800011c6:	86b2                	mv	a3,a2
    800011c8:	863e                	mv	a2,a5
    800011ca:	00000097          	auipc	ra,0x0
    800011ce:	f52080e7          	jalr	-174(ra) # 8000111c <mappages>
    800011d2:	e509                	bnez	a0,800011dc <kvmmap+0x20>
}
    800011d4:	60a2                	ld	ra,8(sp)
    800011d6:	6402                	ld	s0,0(sp)
    800011d8:	0141                	addi	sp,sp,16
    800011da:	8082                	ret
    panic("kvmmap");
    800011dc:	00007517          	auipc	a0,0x7
    800011e0:	f5450513          	addi	a0,a0,-172 # 80008130 <digits+0xf0>
    800011e4:	fffff097          	auipc	ra,0xfffff
    800011e8:	35a080e7          	jalr	858(ra) # 8000053e <panic>

00000000800011ec <kvmmake>:
{
    800011ec:	1101                	addi	sp,sp,-32
    800011ee:	ec06                	sd	ra,24(sp)
    800011f0:	e822                	sd	s0,16(sp)
    800011f2:	e426                	sd	s1,8(sp)
    800011f4:	e04a                	sd	s2,0(sp)
    800011f6:	1000                	addi	s0,sp,32
  kpgtbl = (pagetable_t) kalloc();
    800011f8:	00000097          	auipc	ra,0x0
    800011fc:	8ee080e7          	jalr	-1810(ra) # 80000ae6 <kalloc>
    80001200:	84aa                	mv	s1,a0
  memset(kpgtbl, 0, PGSIZE);
    80001202:	6605                	lui	a2,0x1
    80001204:	4581                	li	a1,0
    80001206:	00000097          	auipc	ra,0x0
    8000120a:	b30080e7          	jalr	-1232(ra) # 80000d36 <memset>
  kvmmap(kpgtbl, UART0, UART0, PGSIZE, PTE_R | PTE_W);
    8000120e:	4719                	li	a4,6
    80001210:	6685                	lui	a3,0x1
    80001212:	10000637          	lui	a2,0x10000
    80001216:	100005b7          	lui	a1,0x10000
    8000121a:	8526                	mv	a0,s1
    8000121c:	00000097          	auipc	ra,0x0
    80001220:	fa0080e7          	jalr	-96(ra) # 800011bc <kvmmap>
  kvmmap(kpgtbl, VIRTIO0, VIRTIO0, PGSIZE, PTE_R | PTE_W);
    80001224:	4719                	li	a4,6
    80001226:	6685                	lui	a3,0x1
    80001228:	10001637          	lui	a2,0x10001
    8000122c:	100015b7          	lui	a1,0x10001
    80001230:	8526                	mv	a0,s1
    80001232:	00000097          	auipc	ra,0x0
    80001236:	f8a080e7          	jalr	-118(ra) # 800011bc <kvmmap>
  kvmmap(kpgtbl, PLIC, PLIC, 0x400000, PTE_R | PTE_W);
    8000123a:	4719                	li	a4,6
    8000123c:	004006b7          	lui	a3,0x400
    80001240:	0c000637          	lui	a2,0xc000
    80001244:	0c0005b7          	lui	a1,0xc000
    80001248:	8526                	mv	a0,s1
    8000124a:	00000097          	auipc	ra,0x0
    8000124e:	f72080e7          	jalr	-142(ra) # 800011bc <kvmmap>
  kvmmap(kpgtbl, KERNBASE, KERNBASE, (uint64)etext-KERNBASE, PTE_R | PTE_X);
    80001252:	00007917          	auipc	s2,0x7
    80001256:	dae90913          	addi	s2,s2,-594 # 80008000 <etext>
    8000125a:	4729                	li	a4,10
    8000125c:	80007697          	auipc	a3,0x80007
    80001260:	da468693          	addi	a3,a3,-604 # 8000 <_entry-0x7fff8000>
    80001264:	4605                	li	a2,1
    80001266:	067e                	slli	a2,a2,0x1f
    80001268:	85b2                	mv	a1,a2
    8000126a:	8526                	mv	a0,s1
    8000126c:	00000097          	auipc	ra,0x0
    80001270:	f50080e7          	jalr	-176(ra) # 800011bc <kvmmap>
  kvmmap(kpgtbl, (uint64)etext, (uint64)etext, PHYSTOP-(uint64)etext, PTE_R | PTE_W);
    80001274:	4719                	li	a4,6
    80001276:	46c5                	li	a3,17
    80001278:	06ee                	slli	a3,a3,0x1b
    8000127a:	412686b3          	sub	a3,a3,s2
    8000127e:	864a                	mv	a2,s2
    80001280:	85ca                	mv	a1,s2
    80001282:	8526                	mv	a0,s1
    80001284:	00000097          	auipc	ra,0x0
    80001288:	f38080e7          	jalr	-200(ra) # 800011bc <kvmmap>
  kvmmap(kpgtbl, TRAMPOLINE, (uint64)trampoline, PGSIZE, PTE_R | PTE_X);
    8000128c:	4729                	li	a4,10
    8000128e:	6685                	lui	a3,0x1
    80001290:	00006617          	auipc	a2,0x6
    80001294:	d7060613          	addi	a2,a2,-656 # 80007000 <_trampoline>
    80001298:	040005b7          	lui	a1,0x4000
    8000129c:	15fd                	addi	a1,a1,-1
    8000129e:	05b2                	slli	a1,a1,0xc
    800012a0:	8526                	mv	a0,s1
    800012a2:	00000097          	auipc	ra,0x0
    800012a6:	f1a080e7          	jalr	-230(ra) # 800011bc <kvmmap>
  proc_mapstacks(kpgtbl);
    800012aa:	8526                	mv	a0,s1
    800012ac:	00000097          	auipc	ra,0x0
    800012b0:	608080e7          	jalr	1544(ra) # 800018b4 <proc_mapstacks>
}
    800012b4:	8526                	mv	a0,s1
    800012b6:	60e2                	ld	ra,24(sp)
    800012b8:	6442                	ld	s0,16(sp)
    800012ba:	64a2                	ld	s1,8(sp)
    800012bc:	6902                	ld	s2,0(sp)
    800012be:	6105                	addi	sp,sp,32
    800012c0:	8082                	ret

00000000800012c2 <kvminit>:
{
    800012c2:	1141                	addi	sp,sp,-16
    800012c4:	e406                	sd	ra,8(sp)
    800012c6:	e022                	sd	s0,0(sp)
    800012c8:	0800                	addi	s0,sp,16
  kernel_pagetable = kvmmake();
    800012ca:	00000097          	auipc	ra,0x0
    800012ce:	f22080e7          	jalr	-222(ra) # 800011ec <kvmmake>
    800012d2:	00007797          	auipc	a5,0x7
    800012d6:	60a7bf23          	sd	a0,1566(a5) # 800088f0 <kernel_pagetable>
}
    800012da:	60a2                	ld	ra,8(sp)
    800012dc:	6402                	ld	s0,0(sp)
    800012de:	0141                	addi	sp,sp,16
    800012e0:	8082                	ret

00000000800012e2 <uvmunmap>:
// Remove npages of mappings starting from va. va must be
// page-aligned. The mappings must exist.
// Optionally free the physical memory.
void
uvmunmap(pagetable_t pagetable, uint64 va, uint64 npages, int do_free)
{
    800012e2:	715d                	addi	sp,sp,-80
    800012e4:	e486                	sd	ra,72(sp)
    800012e6:	e0a2                	sd	s0,64(sp)
    800012e8:	fc26                	sd	s1,56(sp)
    800012ea:	f84a                	sd	s2,48(sp)
    800012ec:	f44e                	sd	s3,40(sp)
    800012ee:	f052                	sd	s4,32(sp)
    800012f0:	ec56                	sd	s5,24(sp)
    800012f2:	e85a                	sd	s6,16(sp)
    800012f4:	e45e                	sd	s7,8(sp)
    800012f6:	0880                	addi	s0,sp,80
  uint64 a;
  pte_t *pte;

  if((va % PGSIZE) != 0)
    800012f8:	03459793          	slli	a5,a1,0x34
    800012fc:	e795                	bnez	a5,80001328 <uvmunmap+0x46>
    800012fe:	8a2a                	mv	s4,a0
    80001300:	892e                	mv	s2,a1
    80001302:	8ab6                	mv	s5,a3
    panic("uvmunmap: not aligned");

  for(a = va; a < va + npages*PGSIZE; a += PGSIZE){
    80001304:	0632                	slli	a2,a2,0xc
    80001306:	00b609b3          	add	s3,a2,a1
    if((pte = walk(pagetable, a, 0)) == 0)
      panic("uvmunmap: walk");
    if((*pte & PTE_V) == 0)
      panic("uvmunmap: not mapped");
    if(PTE_FLAGS(*pte) == PTE_V)
    8000130a:	4b85                	li	s7,1
  for(a = va; a < va + npages*PGSIZE; a += PGSIZE){
    8000130c:	6b05                	lui	s6,0x1
    8000130e:	0735e263          	bltu	a1,s3,80001372 <uvmunmap+0x90>
      uint64 pa = PTE2PA(*pte);
      kfree((void*)pa);
    }
    *pte = 0;
  }
}
    80001312:	60a6                	ld	ra,72(sp)
    80001314:	6406                	ld	s0,64(sp)
    80001316:	74e2                	ld	s1,56(sp)
    80001318:	7942                	ld	s2,48(sp)
    8000131a:	79a2                	ld	s3,40(sp)
    8000131c:	7a02                	ld	s4,32(sp)
    8000131e:	6ae2                	ld	s5,24(sp)
    80001320:	6b42                	ld	s6,16(sp)
    80001322:	6ba2                	ld	s7,8(sp)
    80001324:	6161                	addi	sp,sp,80
    80001326:	8082                	ret
    panic("uvmunmap: not aligned");
    80001328:	00007517          	auipc	a0,0x7
    8000132c:	e1050513          	addi	a0,a0,-496 # 80008138 <digits+0xf8>
    80001330:	fffff097          	auipc	ra,0xfffff
    80001334:	20e080e7          	jalr	526(ra) # 8000053e <panic>
      panic("uvmunmap: walk");
    80001338:	00007517          	auipc	a0,0x7
    8000133c:	e1850513          	addi	a0,a0,-488 # 80008150 <digits+0x110>
    80001340:	fffff097          	auipc	ra,0xfffff
    80001344:	1fe080e7          	jalr	510(ra) # 8000053e <panic>
      panic("uvmunmap: not mapped");
    80001348:	00007517          	auipc	a0,0x7
    8000134c:	e1850513          	addi	a0,a0,-488 # 80008160 <digits+0x120>
    80001350:	fffff097          	auipc	ra,0xfffff
    80001354:	1ee080e7          	jalr	494(ra) # 8000053e <panic>
      panic("uvmunmap: not a leaf");
    80001358:	00007517          	auipc	a0,0x7
    8000135c:	e2050513          	addi	a0,a0,-480 # 80008178 <digits+0x138>
    80001360:	fffff097          	auipc	ra,0xfffff
    80001364:	1de080e7          	jalr	478(ra) # 8000053e <panic>
    *pte = 0;
    80001368:	0004b023          	sd	zero,0(s1)
  for(a = va; a < va + npages*PGSIZE; a += PGSIZE){
    8000136c:	995a                	add	s2,s2,s6
    8000136e:	fb3972e3          	bgeu	s2,s3,80001312 <uvmunmap+0x30>
    if((pte = walk(pagetable, a, 0)) == 0)
    80001372:	4601                	li	a2,0
    80001374:	85ca                	mv	a1,s2
    80001376:	8552                	mv	a0,s4
    80001378:	00000097          	auipc	ra,0x0
    8000137c:	cbc080e7          	jalr	-836(ra) # 80001034 <walk>
    80001380:	84aa                	mv	s1,a0
    80001382:	d95d                	beqz	a0,80001338 <uvmunmap+0x56>
    if((*pte & PTE_V) == 0)
    80001384:	6108                	ld	a0,0(a0)
    80001386:	00157793          	andi	a5,a0,1
    8000138a:	dfdd                	beqz	a5,80001348 <uvmunmap+0x66>
    if(PTE_FLAGS(*pte) == PTE_V)
    8000138c:	3ff57793          	andi	a5,a0,1023
    80001390:	fd7784e3          	beq	a5,s7,80001358 <uvmunmap+0x76>
    if(do_free){
    80001394:	fc0a8ae3          	beqz	s5,80001368 <uvmunmap+0x86>
      uint64 pa = PTE2PA(*pte);
    80001398:	8129                	srli	a0,a0,0xa
      kfree((void*)pa);
    8000139a:	0532                	slli	a0,a0,0xc
    8000139c:	fffff097          	auipc	ra,0xfffff
    800013a0:	64e080e7          	jalr	1614(ra) # 800009ea <kfree>
    800013a4:	b7d1                	j	80001368 <uvmunmap+0x86>

00000000800013a6 <uvmcreate>:

// create an empty user page table.
// returns 0 if out of memory.
pagetable_t
uvmcreate()
{
    800013a6:	1101                	addi	sp,sp,-32
    800013a8:	ec06                	sd	ra,24(sp)
    800013aa:	e822                	sd	s0,16(sp)
    800013ac:	e426                	sd	s1,8(sp)
    800013ae:	1000                	addi	s0,sp,32
  pagetable_t pagetable;
  pagetable = (pagetable_t) kalloc();
    800013b0:	fffff097          	auipc	ra,0xfffff
    800013b4:	736080e7          	jalr	1846(ra) # 80000ae6 <kalloc>
    800013b8:	84aa                	mv	s1,a0
  if(pagetable == 0)
    800013ba:	c519                	beqz	a0,800013c8 <uvmcreate+0x22>
    return 0;
  memset(pagetable, 0, PGSIZE);
    800013bc:	6605                	lui	a2,0x1
    800013be:	4581                	li	a1,0
    800013c0:	00000097          	auipc	ra,0x0
    800013c4:	976080e7          	jalr	-1674(ra) # 80000d36 <memset>
  return pagetable;
}
    800013c8:	8526                	mv	a0,s1
    800013ca:	60e2                	ld	ra,24(sp)
    800013cc:	6442                	ld	s0,16(sp)
    800013ce:	64a2                	ld	s1,8(sp)
    800013d0:	6105                	addi	sp,sp,32
    800013d2:	8082                	ret

00000000800013d4 <uvmfirst>:
// Load the user initcode into address 0 of pagetable,
// for the very first process.
// sz must be less than a page.
void
uvmfirst(pagetable_t pagetable, uchar *src, uint sz)
{
    800013d4:	7179                	addi	sp,sp,-48
    800013d6:	f406                	sd	ra,40(sp)
    800013d8:	f022                	sd	s0,32(sp)
    800013da:	ec26                	sd	s1,24(sp)
    800013dc:	e84a                	sd	s2,16(sp)
    800013de:	e44e                	sd	s3,8(sp)
    800013e0:	e052                	sd	s4,0(sp)
    800013e2:	1800                	addi	s0,sp,48
  char *mem;

  if(sz >= PGSIZE)
    800013e4:	6785                	lui	a5,0x1
    800013e6:	04f67863          	bgeu	a2,a5,80001436 <uvmfirst+0x62>
    800013ea:	8a2a                	mv	s4,a0
    800013ec:	89ae                	mv	s3,a1
    800013ee:	84b2                	mv	s1,a2
    panic("uvmfirst: more than a page");
  mem = kalloc();
    800013f0:	fffff097          	auipc	ra,0xfffff
    800013f4:	6f6080e7          	jalr	1782(ra) # 80000ae6 <kalloc>
    800013f8:	892a                	mv	s2,a0
  memset(mem, 0, PGSIZE);
    800013fa:	6605                	lui	a2,0x1
    800013fc:	4581                	li	a1,0
    800013fe:	00000097          	auipc	ra,0x0
    80001402:	938080e7          	jalr	-1736(ra) # 80000d36 <memset>
  mappages(pagetable, 0, PGSIZE, (uint64)mem, PTE_W|PTE_R|PTE_X|PTE_U);
    80001406:	4779                	li	a4,30
    80001408:	86ca                	mv	a3,s2
    8000140a:	6605                	lui	a2,0x1
    8000140c:	4581                	li	a1,0
    8000140e:	8552                	mv	a0,s4
    80001410:	00000097          	auipc	ra,0x0
    80001414:	d0c080e7          	jalr	-756(ra) # 8000111c <mappages>
  memmove(mem, src, sz);
    80001418:	8626                	mv	a2,s1
    8000141a:	85ce                	mv	a1,s3
    8000141c:	854a                	mv	a0,s2
    8000141e:	00000097          	auipc	ra,0x0
    80001422:	974080e7          	jalr	-1676(ra) # 80000d92 <memmove>
}
    80001426:	70a2                	ld	ra,40(sp)
    80001428:	7402                	ld	s0,32(sp)
    8000142a:	64e2                	ld	s1,24(sp)
    8000142c:	6942                	ld	s2,16(sp)
    8000142e:	69a2                	ld	s3,8(sp)
    80001430:	6a02                	ld	s4,0(sp)
    80001432:	6145                	addi	sp,sp,48
    80001434:	8082                	ret
    panic("uvmfirst: more than a page");
    80001436:	00007517          	auipc	a0,0x7
    8000143a:	d5a50513          	addi	a0,a0,-678 # 80008190 <digits+0x150>
    8000143e:	fffff097          	auipc	ra,0xfffff
    80001442:	100080e7          	jalr	256(ra) # 8000053e <panic>

0000000080001446 <uvmdealloc>:
// newsz.  oldsz and newsz need not be page-aligned, nor does newsz
// need to be less than oldsz.  oldsz can be larger than the actual
// process size.  Returns the new process size.
uint64
uvmdealloc(pagetable_t pagetable, uint64 oldsz, uint64 newsz)
{
    80001446:	1101                	addi	sp,sp,-32
    80001448:	ec06                	sd	ra,24(sp)
    8000144a:	e822                	sd	s0,16(sp)
    8000144c:	e426                	sd	s1,8(sp)
    8000144e:	1000                	addi	s0,sp,32
  if(newsz >= oldsz)
    return oldsz;
    80001450:	84ae                	mv	s1,a1
  if(newsz >= oldsz)
    80001452:	00b67d63          	bgeu	a2,a1,8000146c <uvmdealloc+0x26>
    80001456:	84b2                	mv	s1,a2

  if(PGROUNDUP(newsz) < PGROUNDUP(oldsz)){
    80001458:	6785                	lui	a5,0x1
    8000145a:	17fd                	addi	a5,a5,-1
    8000145c:	00f60733          	add	a4,a2,a5
    80001460:	767d                	lui	a2,0xfffff
    80001462:	8f71                	and	a4,a4,a2
    80001464:	97ae                	add	a5,a5,a1
    80001466:	8ff1                	and	a5,a5,a2
    80001468:	00f76863          	bltu	a4,a5,80001478 <uvmdealloc+0x32>
    int npages = (PGROUNDUP(oldsz) - PGROUNDUP(newsz)) / PGSIZE;
    uvmunmap(pagetable, PGROUNDUP(newsz), npages, 1);
  }

  return newsz;
}
    8000146c:	8526                	mv	a0,s1
    8000146e:	60e2                	ld	ra,24(sp)
    80001470:	6442                	ld	s0,16(sp)
    80001472:	64a2                	ld	s1,8(sp)
    80001474:	6105                	addi	sp,sp,32
    80001476:	8082                	ret
    int npages = (PGROUNDUP(oldsz) - PGROUNDUP(newsz)) / PGSIZE;
    80001478:	8f99                	sub	a5,a5,a4
    8000147a:	83b1                	srli	a5,a5,0xc
    uvmunmap(pagetable, PGROUNDUP(newsz), npages, 1);
    8000147c:	4685                	li	a3,1
    8000147e:	0007861b          	sext.w	a2,a5
    80001482:	85ba                	mv	a1,a4
    80001484:	00000097          	auipc	ra,0x0
    80001488:	e5e080e7          	jalr	-418(ra) # 800012e2 <uvmunmap>
    8000148c:	b7c5                	j	8000146c <uvmdealloc+0x26>

000000008000148e <uvmalloc>:
  if(newsz < oldsz)
    8000148e:	0ab66563          	bltu	a2,a1,80001538 <uvmalloc+0xaa>
{
    80001492:	7139                	addi	sp,sp,-64
    80001494:	fc06                	sd	ra,56(sp)
    80001496:	f822                	sd	s0,48(sp)
    80001498:	f426                	sd	s1,40(sp)
    8000149a:	f04a                	sd	s2,32(sp)
    8000149c:	ec4e                	sd	s3,24(sp)
    8000149e:	e852                	sd	s4,16(sp)
    800014a0:	e456                	sd	s5,8(sp)
    800014a2:	e05a                	sd	s6,0(sp)
    800014a4:	0080                	addi	s0,sp,64
    800014a6:	8aaa                	mv	s5,a0
    800014a8:	8a32                	mv	s4,a2
  oldsz = PGROUNDUP(oldsz);
    800014aa:	6985                	lui	s3,0x1
    800014ac:	19fd                	addi	s3,s3,-1
    800014ae:	95ce                	add	a1,a1,s3
    800014b0:	79fd                	lui	s3,0xfffff
    800014b2:	0135f9b3          	and	s3,a1,s3
  for(a = oldsz; a < newsz; a += PGSIZE){
    800014b6:	08c9f363          	bgeu	s3,a2,8000153c <uvmalloc+0xae>
    800014ba:	894e                	mv	s2,s3
    if(mappages(pagetable, a, PGSIZE, (uint64)mem, PTE_R|PTE_U|xperm) != 0){
    800014bc:	0126eb13          	ori	s6,a3,18
    mem = kalloc();
    800014c0:	fffff097          	auipc	ra,0xfffff
    800014c4:	626080e7          	jalr	1574(ra) # 80000ae6 <kalloc>
    800014c8:	84aa                	mv	s1,a0
    if(mem == 0){
    800014ca:	c51d                	beqz	a0,800014f8 <uvmalloc+0x6a>
    memset(mem, 0, PGSIZE);
    800014cc:	6605                	lui	a2,0x1
    800014ce:	4581                	li	a1,0
    800014d0:	00000097          	auipc	ra,0x0
    800014d4:	866080e7          	jalr	-1946(ra) # 80000d36 <memset>
    if(mappages(pagetable, a, PGSIZE, (uint64)mem, PTE_R|PTE_U|xperm) != 0){
    800014d8:	875a                	mv	a4,s6
    800014da:	86a6                	mv	a3,s1
    800014dc:	6605                	lui	a2,0x1
    800014de:	85ca                	mv	a1,s2
    800014e0:	8556                	mv	a0,s5
    800014e2:	00000097          	auipc	ra,0x0
    800014e6:	c3a080e7          	jalr	-966(ra) # 8000111c <mappages>
    800014ea:	e90d                	bnez	a0,8000151c <uvmalloc+0x8e>
  for(a = oldsz; a < newsz; a += PGSIZE){
    800014ec:	6785                	lui	a5,0x1
    800014ee:	993e                	add	s2,s2,a5
    800014f0:	fd4968e3          	bltu	s2,s4,800014c0 <uvmalloc+0x32>
  return newsz;
    800014f4:	8552                	mv	a0,s4
    800014f6:	a809                	j	80001508 <uvmalloc+0x7a>
      uvmdealloc(pagetable, a, oldsz);
    800014f8:	864e                	mv	a2,s3
    800014fa:	85ca                	mv	a1,s2
    800014fc:	8556                	mv	a0,s5
    800014fe:	00000097          	auipc	ra,0x0
    80001502:	f48080e7          	jalr	-184(ra) # 80001446 <uvmdealloc>
      return 0;
    80001506:	4501                	li	a0,0
}
    80001508:	70e2                	ld	ra,56(sp)
    8000150a:	7442                	ld	s0,48(sp)
    8000150c:	74a2                	ld	s1,40(sp)
    8000150e:	7902                	ld	s2,32(sp)
    80001510:	69e2                	ld	s3,24(sp)
    80001512:	6a42                	ld	s4,16(sp)
    80001514:	6aa2                	ld	s5,8(sp)
    80001516:	6b02                	ld	s6,0(sp)
    80001518:	6121                	addi	sp,sp,64
    8000151a:	8082                	ret
      kfree(mem);
    8000151c:	8526                	mv	a0,s1
    8000151e:	fffff097          	auipc	ra,0xfffff
    80001522:	4cc080e7          	jalr	1228(ra) # 800009ea <kfree>
      uvmdealloc(pagetable, a, oldsz);
    80001526:	864e                	mv	a2,s3
    80001528:	85ca                	mv	a1,s2
    8000152a:	8556                	mv	a0,s5
    8000152c:	00000097          	auipc	ra,0x0
    80001530:	f1a080e7          	jalr	-230(ra) # 80001446 <uvmdealloc>
      return 0;
    80001534:	4501                	li	a0,0
    80001536:	bfc9                	j	80001508 <uvmalloc+0x7a>
    return oldsz;
    80001538:	852e                	mv	a0,a1
}
    8000153a:	8082                	ret
  return newsz;
    8000153c:	8532                	mv	a0,a2
    8000153e:	b7e9                	j	80001508 <uvmalloc+0x7a>

0000000080001540 <freewalk>:

// Recursively free page-table pages.
// All leaf mappings must already have been removed.
void
freewalk(pagetable_t pagetable)
{
    80001540:	7179                	addi	sp,sp,-48
    80001542:	f406                	sd	ra,40(sp)
    80001544:	f022                	sd	s0,32(sp)
    80001546:	ec26                	sd	s1,24(sp)
    80001548:	e84a                	sd	s2,16(sp)
    8000154a:	e44e                	sd	s3,8(sp)
    8000154c:	e052                	sd	s4,0(sp)
    8000154e:	1800                	addi	s0,sp,48
    80001550:	8a2a                	mv	s4,a0
  // there are 2^9 = 512 PTEs in a page table.
  for(int i = 0; i < 512; i++){
    80001552:	84aa                	mv	s1,a0
    80001554:	6905                	lui	s2,0x1
    80001556:	992a                	add	s2,s2,a0
    pte_t pte = pagetable[i];
    if((pte & PTE_V) && (pte & (PTE_R|PTE_W|PTE_X)) == 0){
    80001558:	4985                	li	s3,1
    8000155a:	a821                	j	80001572 <freewalk+0x32>
      // this PTE points to a lower-level page table.
      uint64 child = PTE2PA(pte);
    8000155c:	8129                	srli	a0,a0,0xa
      freewalk((pagetable_t)child);
    8000155e:	0532                	slli	a0,a0,0xc
    80001560:	00000097          	auipc	ra,0x0
    80001564:	fe0080e7          	jalr	-32(ra) # 80001540 <freewalk>
      pagetable[i] = 0;
    80001568:	0004b023          	sd	zero,0(s1)
  for(int i = 0; i < 512; i++){
    8000156c:	04a1                	addi	s1,s1,8
    8000156e:	03248163          	beq	s1,s2,80001590 <freewalk+0x50>
    pte_t pte = pagetable[i];
    80001572:	6088                	ld	a0,0(s1)
    if((pte & PTE_V) && (pte & (PTE_R|PTE_W|PTE_X)) == 0){
    80001574:	00f57793          	andi	a5,a0,15
    80001578:	ff3782e3          	beq	a5,s3,8000155c <freewalk+0x1c>
    } else if(pte & PTE_V){
    8000157c:	8905                	andi	a0,a0,1
    8000157e:	d57d                	beqz	a0,8000156c <freewalk+0x2c>
      panic("freewalk: leaf");
    80001580:	00007517          	auipc	a0,0x7
    80001584:	c3050513          	addi	a0,a0,-976 # 800081b0 <digits+0x170>
    80001588:	fffff097          	auipc	ra,0xfffff
    8000158c:	fb6080e7          	jalr	-74(ra) # 8000053e <panic>
    }
  }
  kfree((void*)pagetable);
    80001590:	8552                	mv	a0,s4
    80001592:	fffff097          	auipc	ra,0xfffff
    80001596:	458080e7          	jalr	1112(ra) # 800009ea <kfree>
}
    8000159a:	70a2                	ld	ra,40(sp)
    8000159c:	7402                	ld	s0,32(sp)
    8000159e:	64e2                	ld	s1,24(sp)
    800015a0:	6942                	ld	s2,16(sp)
    800015a2:	69a2                	ld	s3,8(sp)
    800015a4:	6a02                	ld	s4,0(sp)
    800015a6:	6145                	addi	sp,sp,48
    800015a8:	8082                	ret

00000000800015aa <uvmfree>:

// Free user memory pages,
// then free page-table pages.
void
uvmfree(pagetable_t pagetable, uint64 sz)
{
    800015aa:	1101                	addi	sp,sp,-32
    800015ac:	ec06                	sd	ra,24(sp)
    800015ae:	e822                	sd	s0,16(sp)
    800015b0:	e426                	sd	s1,8(sp)
    800015b2:	1000                	addi	s0,sp,32
    800015b4:	84aa                	mv	s1,a0
  if(sz > 0)
    800015b6:	e999                	bnez	a1,800015cc <uvmfree+0x22>
    uvmunmap(pagetable, 0, PGROUNDUP(sz)/PGSIZE, 1);
  freewalk(pagetable);
    800015b8:	8526                	mv	a0,s1
    800015ba:	00000097          	auipc	ra,0x0
    800015be:	f86080e7          	jalr	-122(ra) # 80001540 <freewalk>
}
    800015c2:	60e2                	ld	ra,24(sp)
    800015c4:	6442                	ld	s0,16(sp)
    800015c6:	64a2                	ld	s1,8(sp)
    800015c8:	6105                	addi	sp,sp,32
    800015ca:	8082                	ret
    uvmunmap(pagetable, 0, PGROUNDUP(sz)/PGSIZE, 1);
    800015cc:	6605                	lui	a2,0x1
    800015ce:	167d                	addi	a2,a2,-1
    800015d0:	962e                	add	a2,a2,a1
    800015d2:	4685                	li	a3,1
    800015d4:	8231                	srli	a2,a2,0xc
    800015d6:	4581                	li	a1,0
    800015d8:	00000097          	auipc	ra,0x0
    800015dc:	d0a080e7          	jalr	-758(ra) # 800012e2 <uvmunmap>
    800015e0:	bfe1                	j	800015b8 <uvmfree+0xe>

00000000800015e2 <uvmcopy>:
  pte_t *pte;
  uint64 pa, i;
  uint flags;
  char *mem;

  for(i = 0; i < sz; i += PGSIZE){
    800015e2:	c679                	beqz	a2,800016b0 <uvmcopy+0xce>
{
    800015e4:	715d                	addi	sp,sp,-80
    800015e6:	e486                	sd	ra,72(sp)
    800015e8:	e0a2                	sd	s0,64(sp)
    800015ea:	fc26                	sd	s1,56(sp)
    800015ec:	f84a                	sd	s2,48(sp)
    800015ee:	f44e                	sd	s3,40(sp)
    800015f0:	f052                	sd	s4,32(sp)
    800015f2:	ec56                	sd	s5,24(sp)
    800015f4:	e85a                	sd	s6,16(sp)
    800015f6:	e45e                	sd	s7,8(sp)
    800015f8:	0880                	addi	s0,sp,80
    800015fa:	8b2a                	mv	s6,a0
    800015fc:	8aae                	mv	s5,a1
    800015fe:	8a32                	mv	s4,a2
  for(i = 0; i < sz; i += PGSIZE){
    80001600:	4981                	li	s3,0
    if((pte = walk(old, i, 0)) == 0)
    80001602:	4601                	li	a2,0
    80001604:	85ce                	mv	a1,s3
    80001606:	855a                	mv	a0,s6
    80001608:	00000097          	auipc	ra,0x0
    8000160c:	a2c080e7          	jalr	-1492(ra) # 80001034 <walk>
    80001610:	c531                	beqz	a0,8000165c <uvmcopy+0x7a>
      panic("uvmcopy: pte should exist");
    if((*pte & PTE_V) == 0)
    80001612:	6118                	ld	a4,0(a0)
    80001614:	00177793          	andi	a5,a4,1
    80001618:	cbb1                	beqz	a5,8000166c <uvmcopy+0x8a>
      panic("uvmcopy: page not present");
    pa = PTE2PA(*pte);
    8000161a:	00a75593          	srli	a1,a4,0xa
    8000161e:	00c59b93          	slli	s7,a1,0xc
    flags = PTE_FLAGS(*pte);
    80001622:	3ff77493          	andi	s1,a4,1023
    if((mem = kalloc()) == 0)
    80001626:	fffff097          	auipc	ra,0xfffff
    8000162a:	4c0080e7          	jalr	1216(ra) # 80000ae6 <kalloc>
    8000162e:	892a                	mv	s2,a0
    80001630:	c939                	beqz	a0,80001686 <uvmcopy+0xa4>
      goto err;
    memmove(mem, (char*)pa, PGSIZE);
    80001632:	6605                	lui	a2,0x1
    80001634:	85de                	mv	a1,s7
    80001636:	fffff097          	auipc	ra,0xfffff
    8000163a:	75c080e7          	jalr	1884(ra) # 80000d92 <memmove>
    if(mappages(new, i, PGSIZE, (uint64)mem, flags) != 0){
    8000163e:	8726                	mv	a4,s1
    80001640:	86ca                	mv	a3,s2
    80001642:	6605                	lui	a2,0x1
    80001644:	85ce                	mv	a1,s3
    80001646:	8556                	mv	a0,s5
    80001648:	00000097          	auipc	ra,0x0
    8000164c:	ad4080e7          	jalr	-1324(ra) # 8000111c <mappages>
    80001650:	e515                	bnez	a0,8000167c <uvmcopy+0x9a>
  for(i = 0; i < sz; i += PGSIZE){
    80001652:	6785                	lui	a5,0x1
    80001654:	99be                	add	s3,s3,a5
    80001656:	fb49e6e3          	bltu	s3,s4,80001602 <uvmcopy+0x20>
    8000165a:	a081                	j	8000169a <uvmcopy+0xb8>
      panic("uvmcopy: pte should exist");
    8000165c:	00007517          	auipc	a0,0x7
    80001660:	b6450513          	addi	a0,a0,-1180 # 800081c0 <digits+0x180>
    80001664:	fffff097          	auipc	ra,0xfffff
    80001668:	eda080e7          	jalr	-294(ra) # 8000053e <panic>
      panic("uvmcopy: page not present");
    8000166c:	00007517          	auipc	a0,0x7
    80001670:	b7450513          	addi	a0,a0,-1164 # 800081e0 <digits+0x1a0>
    80001674:	fffff097          	auipc	ra,0xfffff
    80001678:	eca080e7          	jalr	-310(ra) # 8000053e <panic>
      kfree(mem);
    8000167c:	854a                	mv	a0,s2
    8000167e:	fffff097          	auipc	ra,0xfffff
    80001682:	36c080e7          	jalr	876(ra) # 800009ea <kfree>
    }
  }
  return 0;

 err:
  uvmunmap(new, 0, i / PGSIZE, 1);
    80001686:	4685                	li	a3,1
    80001688:	00c9d613          	srli	a2,s3,0xc
    8000168c:	4581                	li	a1,0
    8000168e:	8556                	mv	a0,s5
    80001690:	00000097          	auipc	ra,0x0
    80001694:	c52080e7          	jalr	-942(ra) # 800012e2 <uvmunmap>
  return -1;
    80001698:	557d                	li	a0,-1
}
    8000169a:	60a6                	ld	ra,72(sp)
    8000169c:	6406                	ld	s0,64(sp)
    8000169e:	74e2                	ld	s1,56(sp)
    800016a0:	7942                	ld	s2,48(sp)
    800016a2:	79a2                	ld	s3,40(sp)
    800016a4:	7a02                	ld	s4,32(sp)
    800016a6:	6ae2                	ld	s5,24(sp)
    800016a8:	6b42                	ld	s6,16(sp)
    800016aa:	6ba2                	ld	s7,8(sp)
    800016ac:	6161                	addi	sp,sp,80
    800016ae:	8082                	ret
  return 0;
    800016b0:	4501                	li	a0,0
}
    800016b2:	8082                	ret

00000000800016b4 <uvmclear>:

// mark a PTE invalid for user access.
// used by exec for the user stack guard page.
void
uvmclear(pagetable_t pagetable, uint64 va)
{
    800016b4:	1141                	addi	sp,sp,-16
    800016b6:	e406                	sd	ra,8(sp)
    800016b8:	e022                	sd	s0,0(sp)
    800016ba:	0800                	addi	s0,sp,16
  pte_t *pte;
  
  pte = walk(pagetable, va, 0);
    800016bc:	4601                	li	a2,0
    800016be:	00000097          	auipc	ra,0x0
    800016c2:	976080e7          	jalr	-1674(ra) # 80001034 <walk>
  if(pte == 0)
    800016c6:	c901                	beqz	a0,800016d6 <uvmclear+0x22>
    panic("uvmclear");
  *pte &= ~PTE_U;
    800016c8:	611c                	ld	a5,0(a0)
    800016ca:	9bbd                	andi	a5,a5,-17
    800016cc:	e11c                	sd	a5,0(a0)
}
    800016ce:	60a2                	ld	ra,8(sp)
    800016d0:	6402                	ld	s0,0(sp)
    800016d2:	0141                	addi	sp,sp,16
    800016d4:	8082                	ret
    panic("uvmclear");
    800016d6:	00007517          	auipc	a0,0x7
    800016da:	b2a50513          	addi	a0,a0,-1238 # 80008200 <digits+0x1c0>
    800016de:	fffff097          	auipc	ra,0xfffff
    800016e2:	e60080e7          	jalr	-416(ra) # 8000053e <panic>

00000000800016e6 <copyout>:
int
copyout(pagetable_t pagetable, uint64 dstva, char *src, uint64 len)
{
  uint64 n, va0, pa0;

  while(len > 0){
    800016e6:	c6bd                	beqz	a3,80001754 <copyout+0x6e>
{
    800016e8:	715d                	addi	sp,sp,-80
    800016ea:	e486                	sd	ra,72(sp)
    800016ec:	e0a2                	sd	s0,64(sp)
    800016ee:	fc26                	sd	s1,56(sp)
    800016f0:	f84a                	sd	s2,48(sp)
    800016f2:	f44e                	sd	s3,40(sp)
    800016f4:	f052                	sd	s4,32(sp)
    800016f6:	ec56                	sd	s5,24(sp)
    800016f8:	e85a                	sd	s6,16(sp)
    800016fa:	e45e                	sd	s7,8(sp)
    800016fc:	e062                	sd	s8,0(sp)
    800016fe:	0880                	addi	s0,sp,80
    80001700:	8b2a                	mv	s6,a0
    80001702:	8c2e                	mv	s8,a1
    80001704:	8a32                	mv	s4,a2
    80001706:	89b6                	mv	s3,a3
    va0 = PGROUNDDOWN(dstva);
    80001708:	7bfd                	lui	s7,0xfffff
    pa0 = walkaddr(pagetable, va0);
    if(pa0 == 0)
      return -1;
    n = PGSIZE - (dstva - va0);
    8000170a:	6a85                	lui	s5,0x1
    8000170c:	a015                	j	80001730 <copyout+0x4a>
    if(n > len)
      n = len;
    memmove((void *)(pa0 + (dstva - va0)), src, n);
    8000170e:	9562                	add	a0,a0,s8
    80001710:	0004861b          	sext.w	a2,s1
    80001714:	85d2                	mv	a1,s4
    80001716:	41250533          	sub	a0,a0,s2
    8000171a:	fffff097          	auipc	ra,0xfffff
    8000171e:	678080e7          	jalr	1656(ra) # 80000d92 <memmove>

    len -= n;
    80001722:	409989b3          	sub	s3,s3,s1
    src += n;
    80001726:	9a26                	add	s4,s4,s1
    dstva = va0 + PGSIZE;
    80001728:	01590c33          	add	s8,s2,s5
  while(len > 0){
    8000172c:	02098263          	beqz	s3,80001750 <copyout+0x6a>
    va0 = PGROUNDDOWN(dstva);
    80001730:	017c7933          	and	s2,s8,s7
    pa0 = walkaddr(pagetable, va0);
    80001734:	85ca                	mv	a1,s2
    80001736:	855a                	mv	a0,s6
    80001738:	00000097          	auipc	ra,0x0
    8000173c:	9a2080e7          	jalr	-1630(ra) # 800010da <walkaddr>
    if(pa0 == 0)
    80001740:	cd01                	beqz	a0,80001758 <copyout+0x72>
    n = PGSIZE - (dstva - va0);
    80001742:	418904b3          	sub	s1,s2,s8
    80001746:	94d6                	add	s1,s1,s5
    if(n > len)
    80001748:	fc99f3e3          	bgeu	s3,s1,8000170e <copyout+0x28>
    8000174c:	84ce                	mv	s1,s3
    8000174e:	b7c1                	j	8000170e <copyout+0x28>
  }
  return 0;
    80001750:	4501                	li	a0,0
    80001752:	a021                	j	8000175a <copyout+0x74>
    80001754:	4501                	li	a0,0
}
    80001756:	8082                	ret
      return -1;
    80001758:	557d                	li	a0,-1
}
    8000175a:	60a6                	ld	ra,72(sp)
    8000175c:	6406                	ld	s0,64(sp)
    8000175e:	74e2                	ld	s1,56(sp)
    80001760:	7942                	ld	s2,48(sp)
    80001762:	79a2                	ld	s3,40(sp)
    80001764:	7a02                	ld	s4,32(sp)
    80001766:	6ae2                	ld	s5,24(sp)
    80001768:	6b42                	ld	s6,16(sp)
    8000176a:	6ba2                	ld	s7,8(sp)
    8000176c:	6c02                	ld	s8,0(sp)
    8000176e:	6161                	addi	sp,sp,80
    80001770:	8082                	ret

0000000080001772 <copyin>:
int
copyin(pagetable_t pagetable, char *dst, uint64 srcva, uint64 len)
{
  uint64 n, va0, pa0;

  while(len > 0){
    80001772:	caa5                	beqz	a3,800017e2 <copyin+0x70>
{
    80001774:	715d                	addi	sp,sp,-80
    80001776:	e486                	sd	ra,72(sp)
    80001778:	e0a2                	sd	s0,64(sp)
    8000177a:	fc26                	sd	s1,56(sp)
    8000177c:	f84a                	sd	s2,48(sp)
    8000177e:	f44e                	sd	s3,40(sp)
    80001780:	f052                	sd	s4,32(sp)
    80001782:	ec56                	sd	s5,24(sp)
    80001784:	e85a                	sd	s6,16(sp)
    80001786:	e45e                	sd	s7,8(sp)
    80001788:	e062                	sd	s8,0(sp)
    8000178a:	0880                	addi	s0,sp,80
    8000178c:	8b2a                	mv	s6,a0
    8000178e:	8a2e                	mv	s4,a1
    80001790:	8c32                	mv	s8,a2
    80001792:	89b6                	mv	s3,a3
    va0 = PGROUNDDOWN(srcva);
    80001794:	7bfd                	lui	s7,0xfffff
    pa0 = walkaddr(pagetable, va0);
    if(pa0 == 0)
      return -1;
    n = PGSIZE - (srcva - va0);
    80001796:	6a85                	lui	s5,0x1
    80001798:	a01d                	j	800017be <copyin+0x4c>
    if(n > len)
      n = len;
    memmove(dst, (void *)(pa0 + (srcva - va0)), n);
    8000179a:	018505b3          	add	a1,a0,s8
    8000179e:	0004861b          	sext.w	a2,s1
    800017a2:	412585b3          	sub	a1,a1,s2
    800017a6:	8552                	mv	a0,s4
    800017a8:	fffff097          	auipc	ra,0xfffff
    800017ac:	5ea080e7          	jalr	1514(ra) # 80000d92 <memmove>

    len -= n;
    800017b0:	409989b3          	sub	s3,s3,s1
    dst += n;
    800017b4:	9a26                	add	s4,s4,s1
    srcva = va0 + PGSIZE;
    800017b6:	01590c33          	add	s8,s2,s5
  while(len > 0){
    800017ba:	02098263          	beqz	s3,800017de <copyin+0x6c>
    va0 = PGROUNDDOWN(srcva);
    800017be:	017c7933          	and	s2,s8,s7
    pa0 = walkaddr(pagetable, va0);
    800017c2:	85ca                	mv	a1,s2
    800017c4:	855a                	mv	a0,s6
    800017c6:	00000097          	auipc	ra,0x0
    800017ca:	914080e7          	jalr	-1772(ra) # 800010da <walkaddr>
    if(pa0 == 0)
    800017ce:	cd01                	beqz	a0,800017e6 <copyin+0x74>
    n = PGSIZE - (srcva - va0);
    800017d0:	418904b3          	sub	s1,s2,s8
    800017d4:	94d6                	add	s1,s1,s5
    if(n > len)
    800017d6:	fc99f2e3          	bgeu	s3,s1,8000179a <copyin+0x28>
    800017da:	84ce                	mv	s1,s3
    800017dc:	bf7d                	j	8000179a <copyin+0x28>
  }
  return 0;
    800017de:	4501                	li	a0,0
    800017e0:	a021                	j	800017e8 <copyin+0x76>
    800017e2:	4501                	li	a0,0
}
    800017e4:	8082                	ret
      return -1;
    800017e6:	557d                	li	a0,-1
}
    800017e8:	60a6                	ld	ra,72(sp)
    800017ea:	6406                	ld	s0,64(sp)
    800017ec:	74e2                	ld	s1,56(sp)
    800017ee:	7942                	ld	s2,48(sp)
    800017f0:	79a2                	ld	s3,40(sp)
    800017f2:	7a02                	ld	s4,32(sp)
    800017f4:	6ae2                	ld	s5,24(sp)
    800017f6:	6b42                	ld	s6,16(sp)
    800017f8:	6ba2                	ld	s7,8(sp)
    800017fa:	6c02                	ld	s8,0(sp)
    800017fc:	6161                	addi	sp,sp,80
    800017fe:	8082                	ret

0000000080001800 <copyinstr>:
copyinstr(pagetable_t pagetable, char *dst, uint64 srcva, uint64 max)
{
  uint64 n, va0, pa0;
  int got_null = 0;

  while(got_null == 0 && max > 0){
    80001800:	c6c5                	beqz	a3,800018a8 <copyinstr+0xa8>
{
    80001802:	715d                	addi	sp,sp,-80
    80001804:	e486                	sd	ra,72(sp)
    80001806:	e0a2                	sd	s0,64(sp)
    80001808:	fc26                	sd	s1,56(sp)
    8000180a:	f84a                	sd	s2,48(sp)
    8000180c:	f44e                	sd	s3,40(sp)
    8000180e:	f052                	sd	s4,32(sp)
    80001810:	ec56                	sd	s5,24(sp)
    80001812:	e85a                	sd	s6,16(sp)
    80001814:	e45e                	sd	s7,8(sp)
    80001816:	0880                	addi	s0,sp,80
    80001818:	8a2a                	mv	s4,a0
    8000181a:	8b2e                	mv	s6,a1
    8000181c:	8bb2                	mv	s7,a2
    8000181e:	84b6                	mv	s1,a3
    va0 = PGROUNDDOWN(srcva);
    80001820:	7afd                	lui	s5,0xfffff
    pa0 = walkaddr(pagetable, va0);
    if(pa0 == 0)
      return -1;
    n = PGSIZE - (srcva - va0);
    80001822:	6985                	lui	s3,0x1
    80001824:	a035                	j	80001850 <copyinstr+0x50>
      n = max;

    char *p = (char *) (pa0 + (srcva - va0));
    while(n > 0){
      if(*p == '\0'){
        *dst = '\0';
    80001826:	00078023          	sb	zero,0(a5) # 1000 <_entry-0x7ffff000>
    8000182a:	4785                	li	a5,1
      dst++;
    }

    srcva = va0 + PGSIZE;
  }
  if(got_null){
    8000182c:	0017b793          	seqz	a5,a5
    80001830:	40f00533          	neg	a0,a5
    return 0;
  } else {
    return -1;
  }
}
    80001834:	60a6                	ld	ra,72(sp)
    80001836:	6406                	ld	s0,64(sp)
    80001838:	74e2                	ld	s1,56(sp)
    8000183a:	7942                	ld	s2,48(sp)
    8000183c:	79a2                	ld	s3,40(sp)
    8000183e:	7a02                	ld	s4,32(sp)
    80001840:	6ae2                	ld	s5,24(sp)
    80001842:	6b42                	ld	s6,16(sp)
    80001844:	6ba2                	ld	s7,8(sp)
    80001846:	6161                	addi	sp,sp,80
    80001848:	8082                	ret
    srcva = va0 + PGSIZE;
    8000184a:	01390bb3          	add	s7,s2,s3
  while(got_null == 0 && max > 0){
    8000184e:	c8a9                	beqz	s1,800018a0 <copyinstr+0xa0>
    va0 = PGROUNDDOWN(srcva);
    80001850:	015bf933          	and	s2,s7,s5
    pa0 = walkaddr(pagetable, va0);
    80001854:	85ca                	mv	a1,s2
    80001856:	8552                	mv	a0,s4
    80001858:	00000097          	auipc	ra,0x0
    8000185c:	882080e7          	jalr	-1918(ra) # 800010da <walkaddr>
    if(pa0 == 0)
    80001860:	c131                	beqz	a0,800018a4 <copyinstr+0xa4>
    n = PGSIZE - (srcva - va0);
    80001862:	41790833          	sub	a6,s2,s7
    80001866:	984e                	add	a6,a6,s3
    if(n > max)
    80001868:	0104f363          	bgeu	s1,a6,8000186e <copyinstr+0x6e>
    8000186c:	8826                	mv	a6,s1
    char *p = (char *) (pa0 + (srcva - va0));
    8000186e:	955e                	add	a0,a0,s7
    80001870:	41250533          	sub	a0,a0,s2
    while(n > 0){
    80001874:	fc080be3          	beqz	a6,8000184a <copyinstr+0x4a>
    80001878:	985a                	add	a6,a6,s6
    8000187a:	87da                	mv	a5,s6
      if(*p == '\0'){
    8000187c:	41650633          	sub	a2,a0,s6
    80001880:	14fd                	addi	s1,s1,-1
    80001882:	9b26                	add	s6,s6,s1
    80001884:	00f60733          	add	a4,a2,a5
    80001888:	00074703          	lbu	a4,0(a4)
    8000188c:	df49                	beqz	a4,80001826 <copyinstr+0x26>
        *dst = *p;
    8000188e:	00e78023          	sb	a4,0(a5)
      --max;
    80001892:	40fb04b3          	sub	s1,s6,a5
      dst++;
    80001896:	0785                	addi	a5,a5,1
    while(n > 0){
    80001898:	ff0796e3          	bne	a5,a6,80001884 <copyinstr+0x84>
      dst++;
    8000189c:	8b42                	mv	s6,a6
    8000189e:	b775                	j	8000184a <copyinstr+0x4a>
    800018a0:	4781                	li	a5,0
    800018a2:	b769                	j	8000182c <copyinstr+0x2c>
      return -1;
    800018a4:	557d                	li	a0,-1
    800018a6:	b779                	j	80001834 <copyinstr+0x34>
  int got_null = 0;
    800018a8:	4781                	li	a5,0
  if(got_null){
    800018aa:	0017b793          	seqz	a5,a5
    800018ae:	40f00533          	neg	a0,a5
}
    800018b2:	8082                	ret

00000000800018b4 <proc_mapstacks>:
// Allocate a page for each process's kernel stack.
// Map it high in memory, followed by an invalid
// guard page.
void
proc_mapstacks(pagetable_t kpgtbl)
{
    800018b4:	7139                	addi	sp,sp,-64
    800018b6:	fc06                	sd	ra,56(sp)
    800018b8:	f822                	sd	s0,48(sp)
    800018ba:	f426                	sd	s1,40(sp)
    800018bc:	f04a                	sd	s2,32(sp)
    800018be:	ec4e                	sd	s3,24(sp)
    800018c0:	e852                	sd	s4,16(sp)
    800018c2:	e456                	sd	s5,8(sp)
    800018c4:	e05a                	sd	s6,0(sp)
    800018c6:	0080                	addi	s0,sp,64
    800018c8:	89aa                	mv	s3,a0
  struct proc *p;
  
  for(p = proc; p < &proc[NPROC]; p++) {
    800018ca:	0000f497          	auipc	s1,0xf
    800018ce:	6d648493          	addi	s1,s1,1750 # 80010fa0 <proc>
    char *pa = kalloc();
    if(pa == 0)
      panic("kalloc");
    uint64 va = KSTACK((int) (p - proc));
    800018d2:	8b26                	mv	s6,s1
    800018d4:	00006a97          	auipc	s5,0x6
    800018d8:	72ca8a93          	addi	s5,s5,1836 # 80008000 <etext>
    800018dc:	04000937          	lui	s2,0x4000
    800018e0:	197d                	addi	s2,s2,-1
    800018e2:	0932                	slli	s2,s2,0xc
  for(p = proc; p < &proc[NPROC]; p++) {
    800018e4:	00015a17          	auipc	s4,0x15
    800018e8:	0bca0a13          	addi	s4,s4,188 # 800169a0 <tickslock>
    char *pa = kalloc();
    800018ec:	fffff097          	auipc	ra,0xfffff
    800018f0:	1fa080e7          	jalr	506(ra) # 80000ae6 <kalloc>
    800018f4:	862a                	mv	a2,a0
    if(pa == 0)
    800018f6:	c131                	beqz	a0,8000193a <proc_mapstacks+0x86>
    uint64 va = KSTACK((int) (p - proc));
    800018f8:	416485b3          	sub	a1,s1,s6
    800018fc:	858d                	srai	a1,a1,0x3
    800018fe:	000ab783          	ld	a5,0(s5)
    80001902:	02f585b3          	mul	a1,a1,a5
    80001906:	2585                	addiw	a1,a1,1
    80001908:	00d5959b          	slliw	a1,a1,0xd
    kvmmap(kpgtbl, va, (uint64)pa, PGSIZE, PTE_R | PTE_W);
    8000190c:	4719                	li	a4,6
    8000190e:	6685                	lui	a3,0x1
    80001910:	40b905b3          	sub	a1,s2,a1
    80001914:	854e                	mv	a0,s3
    80001916:	00000097          	auipc	ra,0x0
    8000191a:	8a6080e7          	jalr	-1882(ra) # 800011bc <kvmmap>
  for(p = proc; p < &proc[NPROC]; p++) {
    8000191e:	16848493          	addi	s1,s1,360
    80001922:	fd4495e3          	bne	s1,s4,800018ec <proc_mapstacks+0x38>
  }
}
    80001926:	70e2                	ld	ra,56(sp)
    80001928:	7442                	ld	s0,48(sp)
    8000192a:	74a2                	ld	s1,40(sp)
    8000192c:	7902                	ld	s2,32(sp)
    8000192e:	69e2                	ld	s3,24(sp)
    80001930:	6a42                	ld	s4,16(sp)
    80001932:	6aa2                	ld	s5,8(sp)
    80001934:	6b02                	ld	s6,0(sp)
    80001936:	6121                	addi	sp,sp,64
    80001938:	8082                	ret
      panic("kalloc");
    8000193a:	00007517          	auipc	a0,0x7
    8000193e:	8d650513          	addi	a0,a0,-1834 # 80008210 <digits+0x1d0>
    80001942:	fffff097          	auipc	ra,0xfffff
    80001946:	bfc080e7          	jalr	-1028(ra) # 8000053e <panic>

000000008000194a <procinit>:

// initialize the proc table.
void
procinit(void)
{
    8000194a:	7139                	addi	sp,sp,-64
    8000194c:	fc06                	sd	ra,56(sp)
    8000194e:	f822                	sd	s0,48(sp)
    80001950:	f426                	sd	s1,40(sp)
    80001952:	f04a                	sd	s2,32(sp)
    80001954:	ec4e                	sd	s3,24(sp)
    80001956:	e852                	sd	s4,16(sp)
    80001958:	e456                	sd	s5,8(sp)
    8000195a:	e05a                	sd	s6,0(sp)
    8000195c:	0080                	addi	s0,sp,64
  struct proc *p;
  
  initlock(&pid_lock, "nextpid");
    8000195e:	00007597          	auipc	a1,0x7
    80001962:	8ba58593          	addi	a1,a1,-1862 # 80008218 <digits+0x1d8>
    80001966:	0000f517          	auipc	a0,0xf
    8000196a:	20a50513          	addi	a0,a0,522 # 80010b70 <pid_lock>
    8000196e:	fffff097          	auipc	ra,0xfffff
    80001972:	23c080e7          	jalr	572(ra) # 80000baa <initlock>
  initlock(&wait_lock, "wait_lock");
    80001976:	00007597          	auipc	a1,0x7
    8000197a:	8aa58593          	addi	a1,a1,-1878 # 80008220 <digits+0x1e0>
    8000197e:	0000f517          	auipc	a0,0xf
    80001982:	20a50513          	addi	a0,a0,522 # 80010b88 <wait_lock>
    80001986:	fffff097          	auipc	ra,0xfffff
    8000198a:	224080e7          	jalr	548(ra) # 80000baa <initlock>
  for(p = proc; p < &proc[NPROC]; p++) {
    8000198e:	0000f497          	auipc	s1,0xf
    80001992:	61248493          	addi	s1,s1,1554 # 80010fa0 <proc>
      initlock(&p->lock, "proc");
    80001996:	00007b17          	auipc	s6,0x7
    8000199a:	89ab0b13          	addi	s6,s6,-1894 # 80008230 <digits+0x1f0>
      p->state = UNUSED;
      p->kstack = KSTACK((int) (p - proc));
    8000199e:	8aa6                	mv	s5,s1
    800019a0:	00006a17          	auipc	s4,0x6
    800019a4:	660a0a13          	addi	s4,s4,1632 # 80008000 <etext>
    800019a8:	04000937          	lui	s2,0x4000
    800019ac:	197d                	addi	s2,s2,-1
    800019ae:	0932                	slli	s2,s2,0xc
  for(p = proc; p < &proc[NPROC]; p++) {
    800019b0:	00015997          	auipc	s3,0x15
    800019b4:	ff098993          	addi	s3,s3,-16 # 800169a0 <tickslock>
      initlock(&p->lock, "proc");
    800019b8:	85da                	mv	a1,s6
    800019ba:	8526                	mv	a0,s1
    800019bc:	fffff097          	auipc	ra,0xfffff
    800019c0:	1ee080e7          	jalr	494(ra) # 80000baa <initlock>
      p->state = UNUSED;
    800019c4:	0004ac23          	sw	zero,24(s1)
      p->kstack = KSTACK((int) (p - proc));
    800019c8:	415487b3          	sub	a5,s1,s5
    800019cc:	878d                	srai	a5,a5,0x3
    800019ce:	000a3703          	ld	a4,0(s4)
    800019d2:	02e787b3          	mul	a5,a5,a4
    800019d6:	2785                	addiw	a5,a5,1
    800019d8:	00d7979b          	slliw	a5,a5,0xd
    800019dc:	40f907b3          	sub	a5,s2,a5
    800019e0:	e0bc                	sd	a5,64(s1)
  for(p = proc; p < &proc[NPROC]; p++) {
    800019e2:	16848493          	addi	s1,s1,360
    800019e6:	fd3499e3          	bne	s1,s3,800019b8 <procinit+0x6e>
  }
}
    800019ea:	70e2                	ld	ra,56(sp)
    800019ec:	7442                	ld	s0,48(sp)
    800019ee:	74a2                	ld	s1,40(sp)
    800019f0:	7902                	ld	s2,32(sp)
    800019f2:	69e2                	ld	s3,24(sp)
    800019f4:	6a42                	ld	s4,16(sp)
    800019f6:	6aa2                	ld	s5,8(sp)
    800019f8:	6b02                	ld	s6,0(sp)
    800019fa:	6121                	addi	sp,sp,64
    800019fc:	8082                	ret

00000000800019fe <cpuid>:
// Must be called with interrupts disabled,
// to prevent race with process being moved
// to a different CPU.
int
cpuid()
{
    800019fe:	1141                	addi	sp,sp,-16
    80001a00:	e422                	sd	s0,8(sp)
    80001a02:	0800                	addi	s0,sp,16
  asm volatile("mv %0, tp" : "=r" (x) );
    80001a04:	8512                	mv	a0,tp
  int id = r_tp();
  return id;
}
    80001a06:	2501                	sext.w	a0,a0
    80001a08:	6422                	ld	s0,8(sp)
    80001a0a:	0141                	addi	sp,sp,16
    80001a0c:	8082                	ret

0000000080001a0e <mycpu>:

// Return this CPU's cpu struct.
// Interrupts must be disabled.
struct cpu*
mycpu(void)
{
    80001a0e:	1141                	addi	sp,sp,-16
    80001a10:	e422                	sd	s0,8(sp)
    80001a12:	0800                	addi	s0,sp,16
    80001a14:	8792                	mv	a5,tp
  int id = cpuid();
  struct cpu *c = &cpus[id];
    80001a16:	2781                	sext.w	a5,a5
    80001a18:	079e                	slli	a5,a5,0x7
  return c;
}
    80001a1a:	0000f517          	auipc	a0,0xf
    80001a1e:	18650513          	addi	a0,a0,390 # 80010ba0 <cpus>
    80001a22:	953e                	add	a0,a0,a5
    80001a24:	6422                	ld	s0,8(sp)
    80001a26:	0141                	addi	sp,sp,16
    80001a28:	8082                	ret

0000000080001a2a <myproc>:

// Return the current struct proc *, or zero if none.
struct proc*
myproc(void)
{
    80001a2a:	1101                	addi	sp,sp,-32
    80001a2c:	ec06                	sd	ra,24(sp)
    80001a2e:	e822                	sd	s0,16(sp)
    80001a30:	e426                	sd	s1,8(sp)
    80001a32:	1000                	addi	s0,sp,32
  push_off();
    80001a34:	fffff097          	auipc	ra,0xfffff
    80001a38:	1ba080e7          	jalr	442(ra) # 80000bee <push_off>
    80001a3c:	8792                	mv	a5,tp
  struct cpu *c = mycpu();
  struct proc *p = c->proc;
    80001a3e:	2781                	sext.w	a5,a5
    80001a40:	079e                	slli	a5,a5,0x7
    80001a42:	0000f717          	auipc	a4,0xf
    80001a46:	12e70713          	addi	a4,a4,302 # 80010b70 <pid_lock>
    80001a4a:	97ba                	add	a5,a5,a4
    80001a4c:	7b84                	ld	s1,48(a5)
  pop_off();
    80001a4e:	fffff097          	auipc	ra,0xfffff
    80001a52:	240080e7          	jalr	576(ra) # 80000c8e <pop_off>
  return p;
}
    80001a56:	8526                	mv	a0,s1
    80001a58:	60e2                	ld	ra,24(sp)
    80001a5a:	6442                	ld	s0,16(sp)
    80001a5c:	64a2                	ld	s1,8(sp)
    80001a5e:	6105                	addi	sp,sp,32
    80001a60:	8082                	ret

0000000080001a62 <forkret>:

// A fork child's very first scheduling by scheduler()
// will swtch to forkret.
void
forkret(void)
{
    80001a62:	1141                	addi	sp,sp,-16
    80001a64:	e406                	sd	ra,8(sp)
    80001a66:	e022                	sd	s0,0(sp)
    80001a68:	0800                	addi	s0,sp,16
  static int first = 1;

  // Still holding p->lock from scheduler.
  release(&myproc()->lock);
    80001a6a:	00000097          	auipc	ra,0x0
    80001a6e:	fc0080e7          	jalr	-64(ra) # 80001a2a <myproc>
    80001a72:	fffff097          	auipc	ra,0xfffff
    80001a76:	27c080e7          	jalr	636(ra) # 80000cee <release>

  if (first) {
    80001a7a:	00007797          	auipc	a5,0x7
    80001a7e:	e067a783          	lw	a5,-506(a5) # 80008880 <first.1>
    80001a82:	eb89                	bnez	a5,80001a94 <forkret+0x32>
    // be run from main().
    first = 0;
    fsinit(ROOTDEV);
  }

  usertrapret();
    80001a84:	00001097          	auipc	ra,0x1
    80001a88:	c5a080e7          	jalr	-934(ra) # 800026de <usertrapret>
}
    80001a8c:	60a2                	ld	ra,8(sp)
    80001a8e:	6402                	ld	s0,0(sp)
    80001a90:	0141                	addi	sp,sp,16
    80001a92:	8082                	ret
    first = 0;
    80001a94:	00007797          	auipc	a5,0x7
    80001a98:	de07a623          	sw	zero,-532(a5) # 80008880 <first.1>
    fsinit(ROOTDEV);
    80001a9c:	4505                	li	a0,1
    80001a9e:	00002097          	auipc	ra,0x2
    80001aa2:	9a8080e7          	jalr	-1624(ra) # 80003446 <fsinit>
    80001aa6:	bff9                	j	80001a84 <forkret+0x22>

0000000080001aa8 <allocpid>:
{
    80001aa8:	1101                	addi	sp,sp,-32
    80001aaa:	ec06                	sd	ra,24(sp)
    80001aac:	e822                	sd	s0,16(sp)
    80001aae:	e426                	sd	s1,8(sp)
    80001ab0:	e04a                	sd	s2,0(sp)
    80001ab2:	1000                	addi	s0,sp,32
  acquire(&pid_lock);
    80001ab4:	0000f917          	auipc	s2,0xf
    80001ab8:	0bc90913          	addi	s2,s2,188 # 80010b70 <pid_lock>
    80001abc:	854a                	mv	a0,s2
    80001abe:	fffff097          	auipc	ra,0xfffff
    80001ac2:	17c080e7          	jalr	380(ra) # 80000c3a <acquire>
  pid = nextpid;
    80001ac6:	00007797          	auipc	a5,0x7
    80001aca:	dbe78793          	addi	a5,a5,-578 # 80008884 <nextpid>
    80001ace:	4384                	lw	s1,0(a5)
  nextpid = nextpid + 1;
    80001ad0:	0014871b          	addiw	a4,s1,1
    80001ad4:	c398                	sw	a4,0(a5)
  release(&pid_lock);
    80001ad6:	854a                	mv	a0,s2
    80001ad8:	fffff097          	auipc	ra,0xfffff
    80001adc:	216080e7          	jalr	534(ra) # 80000cee <release>
}
    80001ae0:	8526                	mv	a0,s1
    80001ae2:	60e2                	ld	ra,24(sp)
    80001ae4:	6442                	ld	s0,16(sp)
    80001ae6:	64a2                	ld	s1,8(sp)
    80001ae8:	6902                	ld	s2,0(sp)
    80001aea:	6105                	addi	sp,sp,32
    80001aec:	8082                	ret

0000000080001aee <proc_pagetable>:
{
    80001aee:	1101                	addi	sp,sp,-32
    80001af0:	ec06                	sd	ra,24(sp)
    80001af2:	e822                	sd	s0,16(sp)
    80001af4:	e426                	sd	s1,8(sp)
    80001af6:	e04a                	sd	s2,0(sp)
    80001af8:	1000                	addi	s0,sp,32
    80001afa:	892a                	mv	s2,a0
  pagetable = uvmcreate();
    80001afc:	00000097          	auipc	ra,0x0
    80001b00:	8aa080e7          	jalr	-1878(ra) # 800013a6 <uvmcreate>
    80001b04:	84aa                	mv	s1,a0
  if(pagetable == 0)
    80001b06:	c121                	beqz	a0,80001b46 <proc_pagetable+0x58>
  if(mappages(pagetable, TRAMPOLINE, PGSIZE,
    80001b08:	4729                	li	a4,10
    80001b0a:	00005697          	auipc	a3,0x5
    80001b0e:	4f668693          	addi	a3,a3,1270 # 80007000 <_trampoline>
    80001b12:	6605                	lui	a2,0x1
    80001b14:	040005b7          	lui	a1,0x4000
    80001b18:	15fd                	addi	a1,a1,-1
    80001b1a:	05b2                	slli	a1,a1,0xc
    80001b1c:	fffff097          	auipc	ra,0xfffff
    80001b20:	600080e7          	jalr	1536(ra) # 8000111c <mappages>
    80001b24:	02054863          	bltz	a0,80001b54 <proc_pagetable+0x66>
  if(mappages(pagetable, TRAPFRAME, PGSIZE,
    80001b28:	4719                	li	a4,6
    80001b2a:	05893683          	ld	a3,88(s2)
    80001b2e:	6605                	lui	a2,0x1
    80001b30:	020005b7          	lui	a1,0x2000
    80001b34:	15fd                	addi	a1,a1,-1
    80001b36:	05b6                	slli	a1,a1,0xd
    80001b38:	8526                	mv	a0,s1
    80001b3a:	fffff097          	auipc	ra,0xfffff
    80001b3e:	5e2080e7          	jalr	1506(ra) # 8000111c <mappages>
    80001b42:	02054163          	bltz	a0,80001b64 <proc_pagetable+0x76>
}
    80001b46:	8526                	mv	a0,s1
    80001b48:	60e2                	ld	ra,24(sp)
    80001b4a:	6442                	ld	s0,16(sp)
    80001b4c:	64a2                	ld	s1,8(sp)
    80001b4e:	6902                	ld	s2,0(sp)
    80001b50:	6105                	addi	sp,sp,32
    80001b52:	8082                	ret
    uvmfree(pagetable, 0);
    80001b54:	4581                	li	a1,0
    80001b56:	8526                	mv	a0,s1
    80001b58:	00000097          	auipc	ra,0x0
    80001b5c:	a52080e7          	jalr	-1454(ra) # 800015aa <uvmfree>
    return 0;
    80001b60:	4481                	li	s1,0
    80001b62:	b7d5                	j	80001b46 <proc_pagetable+0x58>
    uvmunmap(pagetable, TRAMPOLINE, 1, 0);
    80001b64:	4681                	li	a3,0
    80001b66:	4605                	li	a2,1
    80001b68:	040005b7          	lui	a1,0x4000
    80001b6c:	15fd                	addi	a1,a1,-1
    80001b6e:	05b2                	slli	a1,a1,0xc
    80001b70:	8526                	mv	a0,s1
    80001b72:	fffff097          	auipc	ra,0xfffff
    80001b76:	770080e7          	jalr	1904(ra) # 800012e2 <uvmunmap>
    uvmfree(pagetable, 0);
    80001b7a:	4581                	li	a1,0
    80001b7c:	8526                	mv	a0,s1
    80001b7e:	00000097          	auipc	ra,0x0
    80001b82:	a2c080e7          	jalr	-1492(ra) # 800015aa <uvmfree>
    return 0;
    80001b86:	4481                	li	s1,0
    80001b88:	bf7d                	j	80001b46 <proc_pagetable+0x58>

0000000080001b8a <proc_freepagetable>:
{
    80001b8a:	1101                	addi	sp,sp,-32
    80001b8c:	ec06                	sd	ra,24(sp)
    80001b8e:	e822                	sd	s0,16(sp)
    80001b90:	e426                	sd	s1,8(sp)
    80001b92:	e04a                	sd	s2,0(sp)
    80001b94:	1000                	addi	s0,sp,32
    80001b96:	84aa                	mv	s1,a0
    80001b98:	892e                	mv	s2,a1
  uvmunmap(pagetable, TRAMPOLINE, 1, 0);
    80001b9a:	4681                	li	a3,0
    80001b9c:	4605                	li	a2,1
    80001b9e:	040005b7          	lui	a1,0x4000
    80001ba2:	15fd                	addi	a1,a1,-1
    80001ba4:	05b2                	slli	a1,a1,0xc
    80001ba6:	fffff097          	auipc	ra,0xfffff
    80001baa:	73c080e7          	jalr	1852(ra) # 800012e2 <uvmunmap>
  uvmunmap(pagetable, TRAPFRAME, 1, 0);
    80001bae:	4681                	li	a3,0
    80001bb0:	4605                	li	a2,1
    80001bb2:	020005b7          	lui	a1,0x2000
    80001bb6:	15fd                	addi	a1,a1,-1
    80001bb8:	05b6                	slli	a1,a1,0xd
    80001bba:	8526                	mv	a0,s1
    80001bbc:	fffff097          	auipc	ra,0xfffff
    80001bc0:	726080e7          	jalr	1830(ra) # 800012e2 <uvmunmap>
  uvmfree(pagetable, sz);
    80001bc4:	85ca                	mv	a1,s2
    80001bc6:	8526                	mv	a0,s1
    80001bc8:	00000097          	auipc	ra,0x0
    80001bcc:	9e2080e7          	jalr	-1566(ra) # 800015aa <uvmfree>
}
    80001bd0:	60e2                	ld	ra,24(sp)
    80001bd2:	6442                	ld	s0,16(sp)
    80001bd4:	64a2                	ld	s1,8(sp)
    80001bd6:	6902                	ld	s2,0(sp)
    80001bd8:	6105                	addi	sp,sp,32
    80001bda:	8082                	ret

0000000080001bdc <freeproc>:
{
    80001bdc:	1101                	addi	sp,sp,-32
    80001bde:	ec06                	sd	ra,24(sp)
    80001be0:	e822                	sd	s0,16(sp)
    80001be2:	e426                	sd	s1,8(sp)
    80001be4:	1000                	addi	s0,sp,32
    80001be6:	84aa                	mv	s1,a0
  if(p->trapframe)
    80001be8:	6d28                	ld	a0,88(a0)
    80001bea:	c509                	beqz	a0,80001bf4 <freeproc+0x18>
    kfree((void*)p->trapframe);
    80001bec:	fffff097          	auipc	ra,0xfffff
    80001bf0:	dfe080e7          	jalr	-514(ra) # 800009ea <kfree>
  p->trapframe = 0;
    80001bf4:	0404bc23          	sd	zero,88(s1)
  if(p->pagetable)
    80001bf8:	68a8                	ld	a0,80(s1)
    80001bfa:	c511                	beqz	a0,80001c06 <freeproc+0x2a>
    proc_freepagetable(p->pagetable, p->sz);
    80001bfc:	64ac                	ld	a1,72(s1)
    80001bfe:	00000097          	auipc	ra,0x0
    80001c02:	f8c080e7          	jalr	-116(ra) # 80001b8a <proc_freepagetable>
  p->pagetable = 0;
    80001c06:	0404b823          	sd	zero,80(s1)
  p->sz = 0;
    80001c0a:	0404b423          	sd	zero,72(s1)
  p->pid = 0;
    80001c0e:	0204a823          	sw	zero,48(s1)
  p->parent = 0;
    80001c12:	0204bc23          	sd	zero,56(s1)
  p->name[0] = 0;
    80001c16:	14048c23          	sb	zero,344(s1)
  p->chan = 0;
    80001c1a:	0204b023          	sd	zero,32(s1)
  p->killed = 0;
    80001c1e:	0204a423          	sw	zero,40(s1)
  p->xstate = 0;
    80001c22:	0204a623          	sw	zero,44(s1)
  p->state = UNUSED;
    80001c26:	0004ac23          	sw	zero,24(s1)
}
    80001c2a:	60e2                	ld	ra,24(sp)
    80001c2c:	6442                	ld	s0,16(sp)
    80001c2e:	64a2                	ld	s1,8(sp)
    80001c30:	6105                	addi	sp,sp,32
    80001c32:	8082                	ret

0000000080001c34 <allocproc>:
{
    80001c34:	1101                	addi	sp,sp,-32
    80001c36:	ec06                	sd	ra,24(sp)
    80001c38:	e822                	sd	s0,16(sp)
    80001c3a:	e426                	sd	s1,8(sp)
    80001c3c:	e04a                	sd	s2,0(sp)
    80001c3e:	1000                	addi	s0,sp,32
  for(p = proc; p < &proc[NPROC]; p++) {
    80001c40:	0000f497          	auipc	s1,0xf
    80001c44:	36048493          	addi	s1,s1,864 # 80010fa0 <proc>
    80001c48:	00015917          	auipc	s2,0x15
    80001c4c:	d5890913          	addi	s2,s2,-680 # 800169a0 <tickslock>
    acquire(&p->lock);
    80001c50:	8526                	mv	a0,s1
    80001c52:	fffff097          	auipc	ra,0xfffff
    80001c56:	fe8080e7          	jalr	-24(ra) # 80000c3a <acquire>
    if(p->state == UNUSED) {
    80001c5a:	4c9c                	lw	a5,24(s1)
    80001c5c:	cf81                	beqz	a5,80001c74 <allocproc+0x40>
      release(&p->lock);
    80001c5e:	8526                	mv	a0,s1
    80001c60:	fffff097          	auipc	ra,0xfffff
    80001c64:	08e080e7          	jalr	142(ra) # 80000cee <release>
  for(p = proc; p < &proc[NPROC]; p++) {
    80001c68:	16848493          	addi	s1,s1,360
    80001c6c:	ff2492e3          	bne	s1,s2,80001c50 <allocproc+0x1c>
  return 0;
    80001c70:	4481                	li	s1,0
    80001c72:	a889                	j	80001cc4 <allocproc+0x90>
  p->pid = allocpid();
    80001c74:	00000097          	auipc	ra,0x0
    80001c78:	e34080e7          	jalr	-460(ra) # 80001aa8 <allocpid>
    80001c7c:	d888                	sw	a0,48(s1)
  p->state = USED;
    80001c7e:	4785                	li	a5,1
    80001c80:	cc9c                	sw	a5,24(s1)
  if((p->trapframe = (struct trapframe *)kalloc()) == 0){
    80001c82:	fffff097          	auipc	ra,0xfffff
    80001c86:	e64080e7          	jalr	-412(ra) # 80000ae6 <kalloc>
    80001c8a:	892a                	mv	s2,a0
    80001c8c:	eca8                	sd	a0,88(s1)
    80001c8e:	c131                	beqz	a0,80001cd2 <allocproc+0x9e>
  p->pagetable = proc_pagetable(p);
    80001c90:	8526                	mv	a0,s1
    80001c92:	00000097          	auipc	ra,0x0
    80001c96:	e5c080e7          	jalr	-420(ra) # 80001aee <proc_pagetable>
    80001c9a:	892a                	mv	s2,a0
    80001c9c:	e8a8                	sd	a0,80(s1)
  if(p->pagetable == 0){
    80001c9e:	c531                	beqz	a0,80001cea <allocproc+0xb6>
  memset(&p->context, 0, sizeof(p->context));
    80001ca0:	07000613          	li	a2,112
    80001ca4:	4581                	li	a1,0
    80001ca6:	06048513          	addi	a0,s1,96
    80001caa:	fffff097          	auipc	ra,0xfffff
    80001cae:	08c080e7          	jalr	140(ra) # 80000d36 <memset>
  p->context.ra = (uint64)forkret;
    80001cb2:	00000797          	auipc	a5,0x0
    80001cb6:	db078793          	addi	a5,a5,-592 # 80001a62 <forkret>
    80001cba:	f0bc                	sd	a5,96(s1)
  p->context.sp = p->kstack + PGSIZE;
    80001cbc:	60bc                	ld	a5,64(s1)
    80001cbe:	6705                	lui	a4,0x1
    80001cc0:	97ba                	add	a5,a5,a4
    80001cc2:	f4bc                	sd	a5,104(s1)
}
    80001cc4:	8526                	mv	a0,s1
    80001cc6:	60e2                	ld	ra,24(sp)
    80001cc8:	6442                	ld	s0,16(sp)
    80001cca:	64a2                	ld	s1,8(sp)
    80001ccc:	6902                	ld	s2,0(sp)
    80001cce:	6105                	addi	sp,sp,32
    80001cd0:	8082                	ret
    freeproc(p);
    80001cd2:	8526                	mv	a0,s1
    80001cd4:	00000097          	auipc	ra,0x0
    80001cd8:	f08080e7          	jalr	-248(ra) # 80001bdc <freeproc>
    release(&p->lock);
    80001cdc:	8526                	mv	a0,s1
    80001cde:	fffff097          	auipc	ra,0xfffff
    80001ce2:	010080e7          	jalr	16(ra) # 80000cee <release>
    return 0;
    80001ce6:	84ca                	mv	s1,s2
    80001ce8:	bff1                	j	80001cc4 <allocproc+0x90>
    freeproc(p);
    80001cea:	8526                	mv	a0,s1
    80001cec:	00000097          	auipc	ra,0x0
    80001cf0:	ef0080e7          	jalr	-272(ra) # 80001bdc <freeproc>
    release(&p->lock);
    80001cf4:	8526                	mv	a0,s1
    80001cf6:	fffff097          	auipc	ra,0xfffff
    80001cfa:	ff8080e7          	jalr	-8(ra) # 80000cee <release>
    return 0;
    80001cfe:	84ca                	mv	s1,s2
    80001d00:	b7d1                	j	80001cc4 <allocproc+0x90>

0000000080001d02 <userinit>:
{
    80001d02:	1101                	addi	sp,sp,-32
    80001d04:	ec06                	sd	ra,24(sp)
    80001d06:	e822                	sd	s0,16(sp)
    80001d08:	e426                	sd	s1,8(sp)
    80001d0a:	1000                	addi	s0,sp,32
  p = allocproc();
    80001d0c:	00000097          	auipc	ra,0x0
    80001d10:	f28080e7          	jalr	-216(ra) # 80001c34 <allocproc>
    80001d14:	84aa                	mv	s1,a0
  initproc = p;
    80001d16:	00007797          	auipc	a5,0x7
    80001d1a:	bea7b123          	sd	a0,-1054(a5) # 800088f8 <initproc>
  uvmfirst(p->pagetable, initcode, sizeof(initcode));
    80001d1e:	03400613          	li	a2,52
    80001d22:	00007597          	auipc	a1,0x7
    80001d26:	b6e58593          	addi	a1,a1,-1170 # 80008890 <initcode>
    80001d2a:	6928                	ld	a0,80(a0)
    80001d2c:	fffff097          	auipc	ra,0xfffff
    80001d30:	6a8080e7          	jalr	1704(ra) # 800013d4 <uvmfirst>
  p->sz = PGSIZE;
    80001d34:	6785                	lui	a5,0x1
    80001d36:	e4bc                	sd	a5,72(s1)
  p->trapframe->epc = 0;      // user program counter
    80001d38:	6cb8                	ld	a4,88(s1)
    80001d3a:	00073c23          	sd	zero,24(a4) # 1018 <_entry-0x7fffefe8>
  p->trapframe->sp = PGSIZE;  // user stack pointer
    80001d3e:	6cb8                	ld	a4,88(s1)
    80001d40:	fb1c                	sd	a5,48(a4)
  safestrcpy(p->name, "initcode", sizeof(p->name));
    80001d42:	4641                	li	a2,16
    80001d44:	00006597          	auipc	a1,0x6
    80001d48:	4f458593          	addi	a1,a1,1268 # 80008238 <digits+0x1f8>
    80001d4c:	15848513          	addi	a0,s1,344
    80001d50:	fffff097          	auipc	ra,0xfffff
    80001d54:	130080e7          	jalr	304(ra) # 80000e80 <safestrcpy>
  p->cwd = namei("/");
    80001d58:	00006517          	auipc	a0,0x6
    80001d5c:	4f050513          	addi	a0,a0,1264 # 80008248 <digits+0x208>
    80001d60:	00002097          	auipc	ra,0x2
    80001d64:	108080e7          	jalr	264(ra) # 80003e68 <namei>
    80001d68:	14a4b823          	sd	a0,336(s1)
  p->state = RUNNABLE;
    80001d6c:	478d                	li	a5,3
    80001d6e:	cc9c                	sw	a5,24(s1)
  release(&p->lock);
    80001d70:	8526                	mv	a0,s1
    80001d72:	fffff097          	auipc	ra,0xfffff
    80001d76:	f7c080e7          	jalr	-132(ra) # 80000cee <release>
}
    80001d7a:	60e2                	ld	ra,24(sp)
    80001d7c:	6442                	ld	s0,16(sp)
    80001d7e:	64a2                	ld	s1,8(sp)
    80001d80:	6105                	addi	sp,sp,32
    80001d82:	8082                	ret

0000000080001d84 <growproc>:
{
    80001d84:	1101                	addi	sp,sp,-32
    80001d86:	ec06                	sd	ra,24(sp)
    80001d88:	e822                	sd	s0,16(sp)
    80001d8a:	e426                	sd	s1,8(sp)
    80001d8c:	e04a                	sd	s2,0(sp)
    80001d8e:	1000                	addi	s0,sp,32
    80001d90:	892a                	mv	s2,a0
  struct proc *p = myproc();
    80001d92:	00000097          	auipc	ra,0x0
    80001d96:	c98080e7          	jalr	-872(ra) # 80001a2a <myproc>
    80001d9a:	84aa                	mv	s1,a0
  sz = p->sz;
    80001d9c:	652c                	ld	a1,72(a0)
  if(n > 0){
    80001d9e:	01204c63          	bgtz	s2,80001db6 <growproc+0x32>
  } else if(n < 0){
    80001da2:	02094663          	bltz	s2,80001dce <growproc+0x4a>
  p->sz = sz;
    80001da6:	e4ac                	sd	a1,72(s1)
  return 0;
    80001da8:	4501                	li	a0,0
}
    80001daa:	60e2                	ld	ra,24(sp)
    80001dac:	6442                	ld	s0,16(sp)
    80001dae:	64a2                	ld	s1,8(sp)
    80001db0:	6902                	ld	s2,0(sp)
    80001db2:	6105                	addi	sp,sp,32
    80001db4:	8082                	ret
    if((sz = uvmalloc(p->pagetable, sz, sz + n, PTE_W)) == 0) {
    80001db6:	4691                	li	a3,4
    80001db8:	00b90633          	add	a2,s2,a1
    80001dbc:	6928                	ld	a0,80(a0)
    80001dbe:	fffff097          	auipc	ra,0xfffff
    80001dc2:	6d0080e7          	jalr	1744(ra) # 8000148e <uvmalloc>
    80001dc6:	85aa                	mv	a1,a0
    80001dc8:	fd79                	bnez	a0,80001da6 <growproc+0x22>
      return -1;
    80001dca:	557d                	li	a0,-1
    80001dcc:	bff9                	j	80001daa <growproc+0x26>
    sz = uvmdealloc(p->pagetable, sz, sz + n);
    80001dce:	00b90633          	add	a2,s2,a1
    80001dd2:	6928                	ld	a0,80(a0)
    80001dd4:	fffff097          	auipc	ra,0xfffff
    80001dd8:	672080e7          	jalr	1650(ra) # 80001446 <uvmdealloc>
    80001ddc:	85aa                	mv	a1,a0
    80001dde:	b7e1                	j	80001da6 <growproc+0x22>

0000000080001de0 <fork>:
{
    80001de0:	7139                	addi	sp,sp,-64
    80001de2:	fc06                	sd	ra,56(sp)
    80001de4:	f822                	sd	s0,48(sp)
    80001de6:	f426                	sd	s1,40(sp)
    80001de8:	f04a                	sd	s2,32(sp)
    80001dea:	ec4e                	sd	s3,24(sp)
    80001dec:	e852                	sd	s4,16(sp)
    80001dee:	e456                	sd	s5,8(sp)
    80001df0:	0080                	addi	s0,sp,64
  struct proc *p = myproc();
    80001df2:	00000097          	auipc	ra,0x0
    80001df6:	c38080e7          	jalr	-968(ra) # 80001a2a <myproc>
    80001dfa:	8aaa                	mv	s5,a0
  if((np = allocproc()) == 0){
    80001dfc:	00000097          	auipc	ra,0x0
    80001e00:	e38080e7          	jalr	-456(ra) # 80001c34 <allocproc>
    80001e04:	10050c63          	beqz	a0,80001f1c <fork+0x13c>
    80001e08:	8a2a                	mv	s4,a0
  if(uvmcopy(p->pagetable, np->pagetable, p->sz) < 0){
    80001e0a:	048ab603          	ld	a2,72(s5)
    80001e0e:	692c                	ld	a1,80(a0)
    80001e10:	050ab503          	ld	a0,80(s5)
    80001e14:	fffff097          	auipc	ra,0xfffff
    80001e18:	7ce080e7          	jalr	1998(ra) # 800015e2 <uvmcopy>
    80001e1c:	04054863          	bltz	a0,80001e6c <fork+0x8c>
  np->sz = p->sz;
    80001e20:	048ab783          	ld	a5,72(s5)
    80001e24:	04fa3423          	sd	a5,72(s4)
  *(np->trapframe) = *(p->trapframe);
    80001e28:	058ab683          	ld	a3,88(s5)
    80001e2c:	87b6                	mv	a5,a3
    80001e2e:	058a3703          	ld	a4,88(s4)
    80001e32:	12068693          	addi	a3,a3,288
    80001e36:	0007b803          	ld	a6,0(a5) # 1000 <_entry-0x7ffff000>
    80001e3a:	6788                	ld	a0,8(a5)
    80001e3c:	6b8c                	ld	a1,16(a5)
    80001e3e:	6f90                	ld	a2,24(a5)
    80001e40:	01073023          	sd	a6,0(a4)
    80001e44:	e708                	sd	a0,8(a4)
    80001e46:	eb0c                	sd	a1,16(a4)
    80001e48:	ef10                	sd	a2,24(a4)
    80001e4a:	02078793          	addi	a5,a5,32
    80001e4e:	02070713          	addi	a4,a4,32
    80001e52:	fed792e3          	bne	a5,a3,80001e36 <fork+0x56>
  np->trapframe->a0 = 0;
    80001e56:	058a3783          	ld	a5,88(s4)
    80001e5a:	0607b823          	sd	zero,112(a5)
  for(i = 0; i < NOFILE; i++)
    80001e5e:	0d0a8493          	addi	s1,s5,208
    80001e62:	0d0a0913          	addi	s2,s4,208
    80001e66:	150a8993          	addi	s3,s5,336
    80001e6a:	a00d                	j	80001e8c <fork+0xac>
    freeproc(np);
    80001e6c:	8552                	mv	a0,s4
    80001e6e:	00000097          	auipc	ra,0x0
    80001e72:	d6e080e7          	jalr	-658(ra) # 80001bdc <freeproc>
    release(&np->lock);
    80001e76:	8552                	mv	a0,s4
    80001e78:	fffff097          	auipc	ra,0xfffff
    80001e7c:	e76080e7          	jalr	-394(ra) # 80000cee <release>
    return -1;
    80001e80:	597d                	li	s2,-1
    80001e82:	a059                	j	80001f08 <fork+0x128>
  for(i = 0; i < NOFILE; i++)
    80001e84:	04a1                	addi	s1,s1,8
    80001e86:	0921                	addi	s2,s2,8
    80001e88:	01348b63          	beq	s1,s3,80001e9e <fork+0xbe>
    if(p->ofile[i])
    80001e8c:	6088                	ld	a0,0(s1)
    80001e8e:	d97d                	beqz	a0,80001e84 <fork+0xa4>
      np->ofile[i] = filedup(p->ofile[i]);
    80001e90:	00002097          	auipc	ra,0x2
    80001e94:	66e080e7          	jalr	1646(ra) # 800044fe <filedup>
    80001e98:	00a93023          	sd	a0,0(s2)
    80001e9c:	b7e5                	j	80001e84 <fork+0xa4>
  np->cwd = idup(p->cwd);
    80001e9e:	150ab503          	ld	a0,336(s5)
    80001ea2:	00001097          	auipc	ra,0x1
    80001ea6:	7e2080e7          	jalr	2018(ra) # 80003684 <idup>
    80001eaa:	14aa3823          	sd	a0,336(s4)
  safestrcpy(np->name, p->name, sizeof(p->name));
    80001eae:	4641                	li	a2,16
    80001eb0:	158a8593          	addi	a1,s5,344
    80001eb4:	158a0513          	addi	a0,s4,344
    80001eb8:	fffff097          	auipc	ra,0xfffff
    80001ebc:	fc8080e7          	jalr	-56(ra) # 80000e80 <safestrcpy>
  pid = np->pid;
    80001ec0:	030a2903          	lw	s2,48(s4)
  release(&np->lock);
    80001ec4:	8552                	mv	a0,s4
    80001ec6:	fffff097          	auipc	ra,0xfffff
    80001eca:	e28080e7          	jalr	-472(ra) # 80000cee <release>
  acquire(&wait_lock);
    80001ece:	0000f497          	auipc	s1,0xf
    80001ed2:	cba48493          	addi	s1,s1,-838 # 80010b88 <wait_lock>
    80001ed6:	8526                	mv	a0,s1
    80001ed8:	fffff097          	auipc	ra,0xfffff
    80001edc:	d62080e7          	jalr	-670(ra) # 80000c3a <acquire>
  np->parent = p;
    80001ee0:	035a3c23          	sd	s5,56(s4)
  release(&wait_lock);
    80001ee4:	8526                	mv	a0,s1
    80001ee6:	fffff097          	auipc	ra,0xfffff
    80001eea:	e08080e7          	jalr	-504(ra) # 80000cee <release>
  acquire(&np->lock);
    80001eee:	8552                	mv	a0,s4
    80001ef0:	fffff097          	auipc	ra,0xfffff
    80001ef4:	d4a080e7          	jalr	-694(ra) # 80000c3a <acquire>
  np->state = RUNNABLE;
    80001ef8:	478d                	li	a5,3
    80001efa:	00fa2c23          	sw	a5,24(s4)
  release(&np->lock);
    80001efe:	8552                	mv	a0,s4
    80001f00:	fffff097          	auipc	ra,0xfffff
    80001f04:	dee080e7          	jalr	-530(ra) # 80000cee <release>
}
    80001f08:	854a                	mv	a0,s2
    80001f0a:	70e2                	ld	ra,56(sp)
    80001f0c:	7442                	ld	s0,48(sp)
    80001f0e:	74a2                	ld	s1,40(sp)
    80001f10:	7902                	ld	s2,32(sp)
    80001f12:	69e2                	ld	s3,24(sp)
    80001f14:	6a42                	ld	s4,16(sp)
    80001f16:	6aa2                	ld	s5,8(sp)
    80001f18:	6121                	addi	sp,sp,64
    80001f1a:	8082                	ret
    return -1;
    80001f1c:	597d                	li	s2,-1
    80001f1e:	b7ed                	j	80001f08 <fork+0x128>

0000000080001f20 <scheduler>:
{
    80001f20:	7139                	addi	sp,sp,-64
    80001f22:	fc06                	sd	ra,56(sp)
    80001f24:	f822                	sd	s0,48(sp)
    80001f26:	f426                	sd	s1,40(sp)
    80001f28:	f04a                	sd	s2,32(sp)
    80001f2a:	ec4e                	sd	s3,24(sp)
    80001f2c:	e852                	sd	s4,16(sp)
    80001f2e:	e456                	sd	s5,8(sp)
    80001f30:	e05a                	sd	s6,0(sp)
    80001f32:	0080                	addi	s0,sp,64
    80001f34:	8792                	mv	a5,tp
  int id = r_tp();
    80001f36:	2781                	sext.w	a5,a5
  c->proc = 0;
    80001f38:	00779a93          	slli	s5,a5,0x7
    80001f3c:	0000f717          	auipc	a4,0xf
    80001f40:	c3470713          	addi	a4,a4,-972 # 80010b70 <pid_lock>
    80001f44:	9756                	add	a4,a4,s5
    80001f46:	02073823          	sd	zero,48(a4)
        swtch(&c->context, &p->context);
    80001f4a:	0000f717          	auipc	a4,0xf
    80001f4e:	c5e70713          	addi	a4,a4,-930 # 80010ba8 <cpus+0x8>
    80001f52:	9aba                	add	s5,s5,a4
      if(p->state == RUNNABLE) {
    80001f54:	498d                	li	s3,3
        p->state = RUNNING;
    80001f56:	4b11                	li	s6,4
        c->proc = p;
    80001f58:	079e                	slli	a5,a5,0x7
    80001f5a:	0000fa17          	auipc	s4,0xf
    80001f5e:	c16a0a13          	addi	s4,s4,-1002 # 80010b70 <pid_lock>
    80001f62:	9a3e                	add	s4,s4,a5
    for(p = proc; p < &proc[NPROC]; p++) {
    80001f64:	00015917          	auipc	s2,0x15
    80001f68:	a3c90913          	addi	s2,s2,-1476 # 800169a0 <tickslock>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80001f6c:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80001f70:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80001f74:	10079073          	csrw	sstatus,a5
    80001f78:	0000f497          	auipc	s1,0xf
    80001f7c:	02848493          	addi	s1,s1,40 # 80010fa0 <proc>
    80001f80:	a811                	j	80001f94 <scheduler+0x74>
      release(&p->lock);
    80001f82:	8526                	mv	a0,s1
    80001f84:	fffff097          	auipc	ra,0xfffff
    80001f88:	d6a080e7          	jalr	-662(ra) # 80000cee <release>
    for(p = proc; p < &proc[NPROC]; p++) {
    80001f8c:	16848493          	addi	s1,s1,360
    80001f90:	fd248ee3          	beq	s1,s2,80001f6c <scheduler+0x4c>
      acquire(&p->lock);
    80001f94:	8526                	mv	a0,s1
    80001f96:	fffff097          	auipc	ra,0xfffff
    80001f9a:	ca4080e7          	jalr	-860(ra) # 80000c3a <acquire>
      if(p->state == RUNNABLE) {
    80001f9e:	4c9c                	lw	a5,24(s1)
    80001fa0:	ff3791e3          	bne	a5,s3,80001f82 <scheduler+0x62>
        p->state = RUNNING;
    80001fa4:	0164ac23          	sw	s6,24(s1)
        c->proc = p;
    80001fa8:	029a3823          	sd	s1,48(s4)
        swtch(&c->context, &p->context);
    80001fac:	06048593          	addi	a1,s1,96
    80001fb0:	8556                	mv	a0,s5
    80001fb2:	00000097          	auipc	ra,0x0
    80001fb6:	682080e7          	jalr	1666(ra) # 80002634 <swtch>
        c->proc = 0;
    80001fba:	020a3823          	sd	zero,48(s4)
    80001fbe:	b7d1                	j	80001f82 <scheduler+0x62>

0000000080001fc0 <sched>:
{
    80001fc0:	7179                	addi	sp,sp,-48
    80001fc2:	f406                	sd	ra,40(sp)
    80001fc4:	f022                	sd	s0,32(sp)
    80001fc6:	ec26                	sd	s1,24(sp)
    80001fc8:	e84a                	sd	s2,16(sp)
    80001fca:	e44e                	sd	s3,8(sp)
    80001fcc:	1800                	addi	s0,sp,48
  struct proc *p = myproc();
    80001fce:	00000097          	auipc	ra,0x0
    80001fd2:	a5c080e7          	jalr	-1444(ra) # 80001a2a <myproc>
    80001fd6:	84aa                	mv	s1,a0
  if(!holding(&p->lock))
    80001fd8:	fffff097          	auipc	ra,0xfffff
    80001fdc:	be8080e7          	jalr	-1048(ra) # 80000bc0 <holding>
    80001fe0:	c93d                	beqz	a0,80002056 <sched+0x96>
  asm volatile("mv %0, tp" : "=r" (x) );
    80001fe2:	8792                	mv	a5,tp
  if(mycpu()->noff != 1)
    80001fe4:	2781                	sext.w	a5,a5
    80001fe6:	079e                	slli	a5,a5,0x7
    80001fe8:	0000f717          	auipc	a4,0xf
    80001fec:	b8870713          	addi	a4,a4,-1144 # 80010b70 <pid_lock>
    80001ff0:	97ba                	add	a5,a5,a4
    80001ff2:	0a87a703          	lw	a4,168(a5)
    80001ff6:	4785                	li	a5,1
    80001ff8:	06f71763          	bne	a4,a5,80002066 <sched+0xa6>
  if(p->state == RUNNING)
    80001ffc:	4c98                	lw	a4,24(s1)
    80001ffe:	4791                	li	a5,4
    80002000:	06f70b63          	beq	a4,a5,80002076 <sched+0xb6>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002004:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80002008:	8b89                	andi	a5,a5,2
  if(intr_get())
    8000200a:	efb5                	bnez	a5,80002086 <sched+0xc6>
  asm volatile("mv %0, tp" : "=r" (x) );
    8000200c:	8792                	mv	a5,tp
  intena = mycpu()->intena;
    8000200e:	0000f917          	auipc	s2,0xf
    80002012:	b6290913          	addi	s2,s2,-1182 # 80010b70 <pid_lock>
    80002016:	2781                	sext.w	a5,a5
    80002018:	079e                	slli	a5,a5,0x7
    8000201a:	97ca                	add	a5,a5,s2
    8000201c:	0ac7a983          	lw	s3,172(a5)
    80002020:	8792                	mv	a5,tp
  swtch(&p->context, &mycpu()->context);
    80002022:	2781                	sext.w	a5,a5
    80002024:	079e                	slli	a5,a5,0x7
    80002026:	0000f597          	auipc	a1,0xf
    8000202a:	b8258593          	addi	a1,a1,-1150 # 80010ba8 <cpus+0x8>
    8000202e:	95be                	add	a1,a1,a5
    80002030:	06048513          	addi	a0,s1,96
    80002034:	00000097          	auipc	ra,0x0
    80002038:	600080e7          	jalr	1536(ra) # 80002634 <swtch>
    8000203c:	8792                	mv	a5,tp
  mycpu()->intena = intena;
    8000203e:	2781                	sext.w	a5,a5
    80002040:	079e                	slli	a5,a5,0x7
    80002042:	97ca                	add	a5,a5,s2
    80002044:	0b37a623          	sw	s3,172(a5)
}
    80002048:	70a2                	ld	ra,40(sp)
    8000204a:	7402                	ld	s0,32(sp)
    8000204c:	64e2                	ld	s1,24(sp)
    8000204e:	6942                	ld	s2,16(sp)
    80002050:	69a2                	ld	s3,8(sp)
    80002052:	6145                	addi	sp,sp,48
    80002054:	8082                	ret
    panic("sched p->lock");
    80002056:	00006517          	auipc	a0,0x6
    8000205a:	1fa50513          	addi	a0,a0,506 # 80008250 <digits+0x210>
    8000205e:	ffffe097          	auipc	ra,0xffffe
    80002062:	4e0080e7          	jalr	1248(ra) # 8000053e <panic>
    panic("sched locks");
    80002066:	00006517          	auipc	a0,0x6
    8000206a:	1fa50513          	addi	a0,a0,506 # 80008260 <digits+0x220>
    8000206e:	ffffe097          	auipc	ra,0xffffe
    80002072:	4d0080e7          	jalr	1232(ra) # 8000053e <panic>
    panic("sched running");
    80002076:	00006517          	auipc	a0,0x6
    8000207a:	1fa50513          	addi	a0,a0,506 # 80008270 <digits+0x230>
    8000207e:	ffffe097          	auipc	ra,0xffffe
    80002082:	4c0080e7          	jalr	1216(ra) # 8000053e <panic>
    panic("sched interruptible");
    80002086:	00006517          	auipc	a0,0x6
    8000208a:	1fa50513          	addi	a0,a0,506 # 80008280 <digits+0x240>
    8000208e:	ffffe097          	auipc	ra,0xffffe
    80002092:	4b0080e7          	jalr	1200(ra) # 8000053e <panic>

0000000080002096 <yield>:
{
    80002096:	1101                	addi	sp,sp,-32
    80002098:	ec06                	sd	ra,24(sp)
    8000209a:	e822                	sd	s0,16(sp)
    8000209c:	e426                	sd	s1,8(sp)
    8000209e:	1000                	addi	s0,sp,32
  struct proc *p = myproc();
    800020a0:	00000097          	auipc	ra,0x0
    800020a4:	98a080e7          	jalr	-1654(ra) # 80001a2a <myproc>
    800020a8:	84aa                	mv	s1,a0
  acquire(&p->lock);
    800020aa:	fffff097          	auipc	ra,0xfffff
    800020ae:	b90080e7          	jalr	-1136(ra) # 80000c3a <acquire>
  p->state = RUNNABLE;
    800020b2:	478d                	li	a5,3
    800020b4:	cc9c                	sw	a5,24(s1)
  sched();
    800020b6:	00000097          	auipc	ra,0x0
    800020ba:	f0a080e7          	jalr	-246(ra) # 80001fc0 <sched>
  release(&p->lock);
    800020be:	8526                	mv	a0,s1
    800020c0:	fffff097          	auipc	ra,0xfffff
    800020c4:	c2e080e7          	jalr	-978(ra) # 80000cee <release>
}
    800020c8:	60e2                	ld	ra,24(sp)
    800020ca:	6442                	ld	s0,16(sp)
    800020cc:	64a2                	ld	s1,8(sp)
    800020ce:	6105                	addi	sp,sp,32
    800020d0:	8082                	ret

00000000800020d2 <sleep>:

// Atomically release lock and sleep on chan.
// Reacquires lock when awakened.
void
sleep(void *chan, struct spinlock *lk)
{
    800020d2:	7179                	addi	sp,sp,-48
    800020d4:	f406                	sd	ra,40(sp)
    800020d6:	f022                	sd	s0,32(sp)
    800020d8:	ec26                	sd	s1,24(sp)
    800020da:	e84a                	sd	s2,16(sp)
    800020dc:	e44e                	sd	s3,8(sp)
    800020de:	1800                	addi	s0,sp,48
    800020e0:	89aa                	mv	s3,a0
    800020e2:	892e                	mv	s2,a1
  struct proc *p = myproc();
    800020e4:	00000097          	auipc	ra,0x0
    800020e8:	946080e7          	jalr	-1722(ra) # 80001a2a <myproc>
    800020ec:	84aa                	mv	s1,a0
  // Once we hold p->lock, we can be
  // guaranteed that we won't miss any wakeup
  // (wakeup locks p->lock),
  // so it's okay to release lk.

  acquire(&p->lock);  //DOC: sleeplock1
    800020ee:	fffff097          	auipc	ra,0xfffff
    800020f2:	b4c080e7          	jalr	-1204(ra) # 80000c3a <acquire>
  release(lk);
    800020f6:	854a                	mv	a0,s2
    800020f8:	fffff097          	auipc	ra,0xfffff
    800020fc:	bf6080e7          	jalr	-1034(ra) # 80000cee <release>

  // Go to sleep.
  p->chan = chan;
    80002100:	0334b023          	sd	s3,32(s1)
  p->state = SLEEPING;
    80002104:	4789                	li	a5,2
    80002106:	cc9c                	sw	a5,24(s1)

  sched();
    80002108:	00000097          	auipc	ra,0x0
    8000210c:	eb8080e7          	jalr	-328(ra) # 80001fc0 <sched>

  // Tidy up.
  p->chan = 0;
    80002110:	0204b023          	sd	zero,32(s1)

  // Reacquire original lock.
  release(&p->lock);
    80002114:	8526                	mv	a0,s1
    80002116:	fffff097          	auipc	ra,0xfffff
    8000211a:	bd8080e7          	jalr	-1064(ra) # 80000cee <release>
  acquire(lk);
    8000211e:	854a                	mv	a0,s2
    80002120:	fffff097          	auipc	ra,0xfffff
    80002124:	b1a080e7          	jalr	-1254(ra) # 80000c3a <acquire>
}
    80002128:	70a2                	ld	ra,40(sp)
    8000212a:	7402                	ld	s0,32(sp)
    8000212c:	64e2                	ld	s1,24(sp)
    8000212e:	6942                	ld	s2,16(sp)
    80002130:	69a2                	ld	s3,8(sp)
    80002132:	6145                	addi	sp,sp,48
    80002134:	8082                	ret

0000000080002136 <wakeup>:

// Wake up all processes sleeping on chan.
// Must be called without any p->lock.
void
wakeup(void *chan)
{
    80002136:	7139                	addi	sp,sp,-64
    80002138:	fc06                	sd	ra,56(sp)
    8000213a:	f822                	sd	s0,48(sp)
    8000213c:	f426                	sd	s1,40(sp)
    8000213e:	f04a                	sd	s2,32(sp)
    80002140:	ec4e                	sd	s3,24(sp)
    80002142:	e852                	sd	s4,16(sp)
    80002144:	e456                	sd	s5,8(sp)
    80002146:	0080                	addi	s0,sp,64
    80002148:	8a2a                	mv	s4,a0
  struct proc *p;

  for(p = proc; p < &proc[NPROC]; p++) {
    8000214a:	0000f497          	auipc	s1,0xf
    8000214e:	e5648493          	addi	s1,s1,-426 # 80010fa0 <proc>
    if(p != myproc()){
      acquire(&p->lock);
      if(p->state == SLEEPING && p->chan == chan) {
    80002152:	4989                	li	s3,2
        p->state = RUNNABLE;
    80002154:	4a8d                	li	s5,3
  for(p = proc; p < &proc[NPROC]; p++) {
    80002156:	00015917          	auipc	s2,0x15
    8000215a:	84a90913          	addi	s2,s2,-1974 # 800169a0 <tickslock>
    8000215e:	a811                	j	80002172 <wakeup+0x3c>
      }
      release(&p->lock);
    80002160:	8526                	mv	a0,s1
    80002162:	fffff097          	auipc	ra,0xfffff
    80002166:	b8c080e7          	jalr	-1140(ra) # 80000cee <release>
  for(p = proc; p < &proc[NPROC]; p++) {
    8000216a:	16848493          	addi	s1,s1,360
    8000216e:	03248663          	beq	s1,s2,8000219a <wakeup+0x64>
    if(p != myproc()){
    80002172:	00000097          	auipc	ra,0x0
    80002176:	8b8080e7          	jalr	-1864(ra) # 80001a2a <myproc>
    8000217a:	fea488e3          	beq	s1,a0,8000216a <wakeup+0x34>
      acquire(&p->lock);
    8000217e:	8526                	mv	a0,s1
    80002180:	fffff097          	auipc	ra,0xfffff
    80002184:	aba080e7          	jalr	-1350(ra) # 80000c3a <acquire>
      if(p->state == SLEEPING && p->chan == chan) {
    80002188:	4c9c                	lw	a5,24(s1)
    8000218a:	fd379be3          	bne	a5,s3,80002160 <wakeup+0x2a>
    8000218e:	709c                	ld	a5,32(s1)
    80002190:	fd4798e3          	bne	a5,s4,80002160 <wakeup+0x2a>
        p->state = RUNNABLE;
    80002194:	0154ac23          	sw	s5,24(s1)
    80002198:	b7e1                	j	80002160 <wakeup+0x2a>
    }
  }
}
    8000219a:	70e2                	ld	ra,56(sp)
    8000219c:	7442                	ld	s0,48(sp)
    8000219e:	74a2                	ld	s1,40(sp)
    800021a0:	7902                	ld	s2,32(sp)
    800021a2:	69e2                	ld	s3,24(sp)
    800021a4:	6a42                	ld	s4,16(sp)
    800021a6:	6aa2                	ld	s5,8(sp)
    800021a8:	6121                	addi	sp,sp,64
    800021aa:	8082                	ret

00000000800021ac <reparent>:
{
    800021ac:	7179                	addi	sp,sp,-48
    800021ae:	f406                	sd	ra,40(sp)
    800021b0:	f022                	sd	s0,32(sp)
    800021b2:	ec26                	sd	s1,24(sp)
    800021b4:	e84a                	sd	s2,16(sp)
    800021b6:	e44e                	sd	s3,8(sp)
    800021b8:	e052                	sd	s4,0(sp)
    800021ba:	1800                	addi	s0,sp,48
    800021bc:	892a                	mv	s2,a0
  for(pp = proc; pp < &proc[NPROC]; pp++){
    800021be:	0000f497          	auipc	s1,0xf
    800021c2:	de248493          	addi	s1,s1,-542 # 80010fa0 <proc>
      pp->parent = initproc;
    800021c6:	00006a17          	auipc	s4,0x6
    800021ca:	732a0a13          	addi	s4,s4,1842 # 800088f8 <initproc>
  for(pp = proc; pp < &proc[NPROC]; pp++){
    800021ce:	00014997          	auipc	s3,0x14
    800021d2:	7d298993          	addi	s3,s3,2002 # 800169a0 <tickslock>
    800021d6:	a029                	j	800021e0 <reparent+0x34>
    800021d8:	16848493          	addi	s1,s1,360
    800021dc:	01348d63          	beq	s1,s3,800021f6 <reparent+0x4a>
    if(pp->parent == p){
    800021e0:	7c9c                	ld	a5,56(s1)
    800021e2:	ff279be3          	bne	a5,s2,800021d8 <reparent+0x2c>
      pp->parent = initproc;
    800021e6:	000a3503          	ld	a0,0(s4)
    800021ea:	fc88                	sd	a0,56(s1)
      wakeup(initproc);
    800021ec:	00000097          	auipc	ra,0x0
    800021f0:	f4a080e7          	jalr	-182(ra) # 80002136 <wakeup>
    800021f4:	b7d5                	j	800021d8 <reparent+0x2c>
}
    800021f6:	70a2                	ld	ra,40(sp)
    800021f8:	7402                	ld	s0,32(sp)
    800021fa:	64e2                	ld	s1,24(sp)
    800021fc:	6942                	ld	s2,16(sp)
    800021fe:	69a2                	ld	s3,8(sp)
    80002200:	6a02                	ld	s4,0(sp)
    80002202:	6145                	addi	sp,sp,48
    80002204:	8082                	ret

0000000080002206 <exit>:
{
    80002206:	7179                	addi	sp,sp,-48
    80002208:	f406                	sd	ra,40(sp)
    8000220a:	f022                	sd	s0,32(sp)
    8000220c:	ec26                	sd	s1,24(sp)
    8000220e:	e84a                	sd	s2,16(sp)
    80002210:	e44e                	sd	s3,8(sp)
    80002212:	e052                	sd	s4,0(sp)
    80002214:	1800                	addi	s0,sp,48
    80002216:	8a2a                	mv	s4,a0
  struct proc *p = myproc();
    80002218:	00000097          	auipc	ra,0x0
    8000221c:	812080e7          	jalr	-2030(ra) # 80001a2a <myproc>
    80002220:	89aa                	mv	s3,a0
  if(p == initproc)
    80002222:	00006797          	auipc	a5,0x6
    80002226:	6d67b783          	ld	a5,1750(a5) # 800088f8 <initproc>
    8000222a:	0d050493          	addi	s1,a0,208
    8000222e:	15050913          	addi	s2,a0,336
    80002232:	02a79363          	bne	a5,a0,80002258 <exit+0x52>
    panic("init exiting");
    80002236:	00006517          	auipc	a0,0x6
    8000223a:	06250513          	addi	a0,a0,98 # 80008298 <digits+0x258>
    8000223e:	ffffe097          	auipc	ra,0xffffe
    80002242:	300080e7          	jalr	768(ra) # 8000053e <panic>
      fileclose(f);
    80002246:	00002097          	auipc	ra,0x2
    8000224a:	30a080e7          	jalr	778(ra) # 80004550 <fileclose>
      p->ofile[fd] = 0;
    8000224e:	0004b023          	sd	zero,0(s1)
  for(int fd = 0; fd < NOFILE; fd++){
    80002252:	04a1                	addi	s1,s1,8
    80002254:	01248563          	beq	s1,s2,8000225e <exit+0x58>
    if(p->ofile[fd]){
    80002258:	6088                	ld	a0,0(s1)
    8000225a:	f575                	bnez	a0,80002246 <exit+0x40>
    8000225c:	bfdd                	j	80002252 <exit+0x4c>
  begin_op();
    8000225e:	00002097          	auipc	ra,0x2
    80002262:	e26080e7          	jalr	-474(ra) # 80004084 <begin_op>
  iput(p->cwd);
    80002266:	1509b503          	ld	a0,336(s3)
    8000226a:	00001097          	auipc	ra,0x1
    8000226e:	612080e7          	jalr	1554(ra) # 8000387c <iput>
  end_op();
    80002272:	00002097          	auipc	ra,0x2
    80002276:	e92080e7          	jalr	-366(ra) # 80004104 <end_op>
  p->cwd = 0;
    8000227a:	1409b823          	sd	zero,336(s3)
  acquire(&wait_lock);
    8000227e:	0000f497          	auipc	s1,0xf
    80002282:	90a48493          	addi	s1,s1,-1782 # 80010b88 <wait_lock>
    80002286:	8526                	mv	a0,s1
    80002288:	fffff097          	auipc	ra,0xfffff
    8000228c:	9b2080e7          	jalr	-1614(ra) # 80000c3a <acquire>
  reparent(p);
    80002290:	854e                	mv	a0,s3
    80002292:	00000097          	auipc	ra,0x0
    80002296:	f1a080e7          	jalr	-230(ra) # 800021ac <reparent>
  wakeup(p->parent);
    8000229a:	0389b503          	ld	a0,56(s3)
    8000229e:	00000097          	auipc	ra,0x0
    800022a2:	e98080e7          	jalr	-360(ra) # 80002136 <wakeup>
  acquire(&p->lock);
    800022a6:	854e                	mv	a0,s3
    800022a8:	fffff097          	auipc	ra,0xfffff
    800022ac:	992080e7          	jalr	-1646(ra) # 80000c3a <acquire>
  p->xstate = status;
    800022b0:	0349a623          	sw	s4,44(s3)
  p->state = ZOMBIE;
    800022b4:	4795                	li	a5,5
    800022b6:	00f9ac23          	sw	a5,24(s3)
  release(&wait_lock);
    800022ba:	8526                	mv	a0,s1
    800022bc:	fffff097          	auipc	ra,0xfffff
    800022c0:	a32080e7          	jalr	-1486(ra) # 80000cee <release>
  sched();
    800022c4:	00000097          	auipc	ra,0x0
    800022c8:	cfc080e7          	jalr	-772(ra) # 80001fc0 <sched>
  panic("zombie exit");
    800022cc:	00006517          	auipc	a0,0x6
    800022d0:	fdc50513          	addi	a0,a0,-36 # 800082a8 <digits+0x268>
    800022d4:	ffffe097          	auipc	ra,0xffffe
    800022d8:	26a080e7          	jalr	618(ra) # 8000053e <panic>

00000000800022dc <kill>:
// Kill the process with the given pid.
// The victim won't exit until it tries to return
// to user space (see usertrap() in trap.c).
int
kill(int pid)
{
    800022dc:	7179                	addi	sp,sp,-48
    800022de:	f406                	sd	ra,40(sp)
    800022e0:	f022                	sd	s0,32(sp)
    800022e2:	ec26                	sd	s1,24(sp)
    800022e4:	e84a                	sd	s2,16(sp)
    800022e6:	e44e                	sd	s3,8(sp)
    800022e8:	1800                	addi	s0,sp,48
    800022ea:	892a                	mv	s2,a0
  struct proc *p;

  for(p = proc; p < &proc[NPROC]; p++){
    800022ec:	0000f497          	auipc	s1,0xf
    800022f0:	cb448493          	addi	s1,s1,-844 # 80010fa0 <proc>
    800022f4:	00014997          	auipc	s3,0x14
    800022f8:	6ac98993          	addi	s3,s3,1708 # 800169a0 <tickslock>
    acquire(&p->lock);
    800022fc:	8526                	mv	a0,s1
    800022fe:	fffff097          	auipc	ra,0xfffff
    80002302:	93c080e7          	jalr	-1732(ra) # 80000c3a <acquire>
    if(p->pid == pid){
    80002306:	589c                	lw	a5,48(s1)
    80002308:	01278d63          	beq	a5,s2,80002322 <kill+0x46>
        p->state = RUNNABLE;
      }
      release(&p->lock);
      return 0;
    }
    release(&p->lock);
    8000230c:	8526                	mv	a0,s1
    8000230e:	fffff097          	auipc	ra,0xfffff
    80002312:	9e0080e7          	jalr	-1568(ra) # 80000cee <release>
  for(p = proc; p < &proc[NPROC]; p++){
    80002316:	16848493          	addi	s1,s1,360
    8000231a:	ff3491e3          	bne	s1,s3,800022fc <kill+0x20>
  }
  return -1;
    8000231e:	557d                	li	a0,-1
    80002320:	a829                	j	8000233a <kill+0x5e>
      p->killed = 1;
    80002322:	4785                	li	a5,1
    80002324:	d49c                	sw	a5,40(s1)
      if(p->state == SLEEPING){
    80002326:	4c98                	lw	a4,24(s1)
    80002328:	4789                	li	a5,2
    8000232a:	00f70f63          	beq	a4,a5,80002348 <kill+0x6c>
      release(&p->lock);
    8000232e:	8526                	mv	a0,s1
    80002330:	fffff097          	auipc	ra,0xfffff
    80002334:	9be080e7          	jalr	-1602(ra) # 80000cee <release>
      return 0;
    80002338:	4501                	li	a0,0
}
    8000233a:	70a2                	ld	ra,40(sp)
    8000233c:	7402                	ld	s0,32(sp)
    8000233e:	64e2                	ld	s1,24(sp)
    80002340:	6942                	ld	s2,16(sp)
    80002342:	69a2                	ld	s3,8(sp)
    80002344:	6145                	addi	sp,sp,48
    80002346:	8082                	ret
        p->state = RUNNABLE;
    80002348:	478d                	li	a5,3
    8000234a:	cc9c                	sw	a5,24(s1)
    8000234c:	b7cd                	j	8000232e <kill+0x52>

000000008000234e <setkilled>:

void
setkilled(struct proc *p)
{
    8000234e:	1101                	addi	sp,sp,-32
    80002350:	ec06                	sd	ra,24(sp)
    80002352:	e822                	sd	s0,16(sp)
    80002354:	e426                	sd	s1,8(sp)
    80002356:	1000                	addi	s0,sp,32
    80002358:	84aa                	mv	s1,a0
  acquire(&p->lock);
    8000235a:	fffff097          	auipc	ra,0xfffff
    8000235e:	8e0080e7          	jalr	-1824(ra) # 80000c3a <acquire>
  p->killed = 1;
    80002362:	4785                	li	a5,1
    80002364:	d49c                	sw	a5,40(s1)
  release(&p->lock);
    80002366:	8526                	mv	a0,s1
    80002368:	fffff097          	auipc	ra,0xfffff
    8000236c:	986080e7          	jalr	-1658(ra) # 80000cee <release>
}
    80002370:	60e2                	ld	ra,24(sp)
    80002372:	6442                	ld	s0,16(sp)
    80002374:	64a2                	ld	s1,8(sp)
    80002376:	6105                	addi	sp,sp,32
    80002378:	8082                	ret

000000008000237a <killed>:

int
killed(struct proc *p)
{
    8000237a:	1101                	addi	sp,sp,-32
    8000237c:	ec06                	sd	ra,24(sp)
    8000237e:	e822                	sd	s0,16(sp)
    80002380:	e426                	sd	s1,8(sp)
    80002382:	e04a                	sd	s2,0(sp)
    80002384:	1000                	addi	s0,sp,32
    80002386:	84aa                	mv	s1,a0
  int k;
  
  acquire(&p->lock);
    80002388:	fffff097          	auipc	ra,0xfffff
    8000238c:	8b2080e7          	jalr	-1870(ra) # 80000c3a <acquire>
  k = p->killed;
    80002390:	0284a903          	lw	s2,40(s1)
  release(&p->lock);
    80002394:	8526                	mv	a0,s1
    80002396:	fffff097          	auipc	ra,0xfffff
    8000239a:	958080e7          	jalr	-1704(ra) # 80000cee <release>
  return k;
}
    8000239e:	854a                	mv	a0,s2
    800023a0:	60e2                	ld	ra,24(sp)
    800023a2:	6442                	ld	s0,16(sp)
    800023a4:	64a2                	ld	s1,8(sp)
    800023a6:	6902                	ld	s2,0(sp)
    800023a8:	6105                	addi	sp,sp,32
    800023aa:	8082                	ret

00000000800023ac <wait>:
{
    800023ac:	715d                	addi	sp,sp,-80
    800023ae:	e486                	sd	ra,72(sp)
    800023b0:	e0a2                	sd	s0,64(sp)
    800023b2:	fc26                	sd	s1,56(sp)
    800023b4:	f84a                	sd	s2,48(sp)
    800023b6:	f44e                	sd	s3,40(sp)
    800023b8:	f052                	sd	s4,32(sp)
    800023ba:	ec56                	sd	s5,24(sp)
    800023bc:	e85a                	sd	s6,16(sp)
    800023be:	e45e                	sd	s7,8(sp)
    800023c0:	e062                	sd	s8,0(sp)
    800023c2:	0880                	addi	s0,sp,80
    800023c4:	8b2a                	mv	s6,a0
  struct proc *p = myproc();
    800023c6:	fffff097          	auipc	ra,0xfffff
    800023ca:	664080e7          	jalr	1636(ra) # 80001a2a <myproc>
    800023ce:	892a                	mv	s2,a0
  acquire(&wait_lock);
    800023d0:	0000e517          	auipc	a0,0xe
    800023d4:	7b850513          	addi	a0,a0,1976 # 80010b88 <wait_lock>
    800023d8:	fffff097          	auipc	ra,0xfffff
    800023dc:	862080e7          	jalr	-1950(ra) # 80000c3a <acquire>
    havekids = 0;
    800023e0:	4b81                	li	s7,0
        if(pp->state == ZOMBIE){
    800023e2:	4a15                	li	s4,5
        havekids = 1;
    800023e4:	4a85                	li	s5,1
    for(pp = proc; pp < &proc[NPROC]; pp++){
    800023e6:	00014997          	auipc	s3,0x14
    800023ea:	5ba98993          	addi	s3,s3,1466 # 800169a0 <tickslock>
    sleep(p, &wait_lock);  //DOC: wait-sleep
    800023ee:	0000ec17          	auipc	s8,0xe
    800023f2:	79ac0c13          	addi	s8,s8,1946 # 80010b88 <wait_lock>
    havekids = 0;
    800023f6:	875e                	mv	a4,s7
    for(pp = proc; pp < &proc[NPROC]; pp++){
    800023f8:	0000f497          	auipc	s1,0xf
    800023fc:	ba848493          	addi	s1,s1,-1112 # 80010fa0 <proc>
    80002400:	a0bd                	j	8000246e <wait+0xc2>
          pid = pp->pid;
    80002402:	0304a983          	lw	s3,48(s1)
          if(addr != 0 && copyout(p->pagetable, addr, (char *)&pp->xstate,
    80002406:	000b0e63          	beqz	s6,80002422 <wait+0x76>
    8000240a:	4691                	li	a3,4
    8000240c:	02c48613          	addi	a2,s1,44
    80002410:	85da                	mv	a1,s6
    80002412:	05093503          	ld	a0,80(s2)
    80002416:	fffff097          	auipc	ra,0xfffff
    8000241a:	2d0080e7          	jalr	720(ra) # 800016e6 <copyout>
    8000241e:	02054563          	bltz	a0,80002448 <wait+0x9c>
          freeproc(pp);
    80002422:	8526                	mv	a0,s1
    80002424:	fffff097          	auipc	ra,0xfffff
    80002428:	7b8080e7          	jalr	1976(ra) # 80001bdc <freeproc>
          release(&pp->lock);
    8000242c:	8526                	mv	a0,s1
    8000242e:	fffff097          	auipc	ra,0xfffff
    80002432:	8c0080e7          	jalr	-1856(ra) # 80000cee <release>
          release(&wait_lock);
    80002436:	0000e517          	auipc	a0,0xe
    8000243a:	75250513          	addi	a0,a0,1874 # 80010b88 <wait_lock>
    8000243e:	fffff097          	auipc	ra,0xfffff
    80002442:	8b0080e7          	jalr	-1872(ra) # 80000cee <release>
          return pid;
    80002446:	a0b5                	j	800024b2 <wait+0x106>
            release(&pp->lock);
    80002448:	8526                	mv	a0,s1
    8000244a:	fffff097          	auipc	ra,0xfffff
    8000244e:	8a4080e7          	jalr	-1884(ra) # 80000cee <release>
            release(&wait_lock);
    80002452:	0000e517          	auipc	a0,0xe
    80002456:	73650513          	addi	a0,a0,1846 # 80010b88 <wait_lock>
    8000245a:	fffff097          	auipc	ra,0xfffff
    8000245e:	894080e7          	jalr	-1900(ra) # 80000cee <release>
            return -1;
    80002462:	59fd                	li	s3,-1
    80002464:	a0b9                	j	800024b2 <wait+0x106>
    for(pp = proc; pp < &proc[NPROC]; pp++){
    80002466:	16848493          	addi	s1,s1,360
    8000246a:	03348463          	beq	s1,s3,80002492 <wait+0xe6>
      if(pp->parent == p){
    8000246e:	7c9c                	ld	a5,56(s1)
    80002470:	ff279be3          	bne	a5,s2,80002466 <wait+0xba>
        acquire(&pp->lock);
    80002474:	8526                	mv	a0,s1
    80002476:	ffffe097          	auipc	ra,0xffffe
    8000247a:	7c4080e7          	jalr	1988(ra) # 80000c3a <acquire>
        if(pp->state == ZOMBIE){
    8000247e:	4c9c                	lw	a5,24(s1)
    80002480:	f94781e3          	beq	a5,s4,80002402 <wait+0x56>
        release(&pp->lock);
    80002484:	8526                	mv	a0,s1
    80002486:	fffff097          	auipc	ra,0xfffff
    8000248a:	868080e7          	jalr	-1944(ra) # 80000cee <release>
        havekids = 1;
    8000248e:	8756                	mv	a4,s5
    80002490:	bfd9                	j	80002466 <wait+0xba>
    if(!havekids || killed(p)){
    80002492:	c719                	beqz	a4,800024a0 <wait+0xf4>
    80002494:	854a                	mv	a0,s2
    80002496:	00000097          	auipc	ra,0x0
    8000249a:	ee4080e7          	jalr	-284(ra) # 8000237a <killed>
    8000249e:	c51d                	beqz	a0,800024cc <wait+0x120>
      release(&wait_lock);
    800024a0:	0000e517          	auipc	a0,0xe
    800024a4:	6e850513          	addi	a0,a0,1768 # 80010b88 <wait_lock>
    800024a8:	fffff097          	auipc	ra,0xfffff
    800024ac:	846080e7          	jalr	-1978(ra) # 80000cee <release>
      return -1;
    800024b0:	59fd                	li	s3,-1
}
    800024b2:	854e                	mv	a0,s3
    800024b4:	60a6                	ld	ra,72(sp)
    800024b6:	6406                	ld	s0,64(sp)
    800024b8:	74e2                	ld	s1,56(sp)
    800024ba:	7942                	ld	s2,48(sp)
    800024bc:	79a2                	ld	s3,40(sp)
    800024be:	7a02                	ld	s4,32(sp)
    800024c0:	6ae2                	ld	s5,24(sp)
    800024c2:	6b42                	ld	s6,16(sp)
    800024c4:	6ba2                	ld	s7,8(sp)
    800024c6:	6c02                	ld	s8,0(sp)
    800024c8:	6161                	addi	sp,sp,80
    800024ca:	8082                	ret
    sleep(p, &wait_lock);  //DOC: wait-sleep
    800024cc:	85e2                	mv	a1,s8
    800024ce:	854a                	mv	a0,s2
    800024d0:	00000097          	auipc	ra,0x0
    800024d4:	c02080e7          	jalr	-1022(ra) # 800020d2 <sleep>
    havekids = 0;
    800024d8:	bf39                	j	800023f6 <wait+0x4a>

00000000800024da <either_copyout>:
// Copy to either a user address, or kernel address,
// depending on usr_dst.
// Returns 0 on success, -1 on error.
int
either_copyout(int user_dst, uint64 dst, void *src, uint64 len)
{
    800024da:	7179                	addi	sp,sp,-48
    800024dc:	f406                	sd	ra,40(sp)
    800024de:	f022                	sd	s0,32(sp)
    800024e0:	ec26                	sd	s1,24(sp)
    800024e2:	e84a                	sd	s2,16(sp)
    800024e4:	e44e                	sd	s3,8(sp)
    800024e6:	e052                	sd	s4,0(sp)
    800024e8:	1800                	addi	s0,sp,48
    800024ea:	84aa                	mv	s1,a0
    800024ec:	892e                	mv	s2,a1
    800024ee:	89b2                	mv	s3,a2
    800024f0:	8a36                	mv	s4,a3
  struct proc *p = myproc();
    800024f2:	fffff097          	auipc	ra,0xfffff
    800024f6:	538080e7          	jalr	1336(ra) # 80001a2a <myproc>
  if(user_dst){
    800024fa:	c08d                	beqz	s1,8000251c <either_copyout+0x42>
    return copyout(p->pagetable, dst, src, len);
    800024fc:	86d2                	mv	a3,s4
    800024fe:	864e                	mv	a2,s3
    80002500:	85ca                	mv	a1,s2
    80002502:	6928                	ld	a0,80(a0)
    80002504:	fffff097          	auipc	ra,0xfffff
    80002508:	1e2080e7          	jalr	482(ra) # 800016e6 <copyout>
  } else {
    memmove((char *)dst, src, len);
    return 0;
  }
}
    8000250c:	70a2                	ld	ra,40(sp)
    8000250e:	7402                	ld	s0,32(sp)
    80002510:	64e2                	ld	s1,24(sp)
    80002512:	6942                	ld	s2,16(sp)
    80002514:	69a2                	ld	s3,8(sp)
    80002516:	6a02                	ld	s4,0(sp)
    80002518:	6145                	addi	sp,sp,48
    8000251a:	8082                	ret
    memmove((char *)dst, src, len);
    8000251c:	000a061b          	sext.w	a2,s4
    80002520:	85ce                	mv	a1,s3
    80002522:	854a                	mv	a0,s2
    80002524:	fffff097          	auipc	ra,0xfffff
    80002528:	86e080e7          	jalr	-1938(ra) # 80000d92 <memmove>
    return 0;
    8000252c:	8526                	mv	a0,s1
    8000252e:	bff9                	j	8000250c <either_copyout+0x32>

0000000080002530 <either_copyin>:
// Copy from either a user address, or kernel address,
// depending on usr_src.
// Returns 0 on success, -1 on error.
int
either_copyin(void *dst, int user_src, uint64 src, uint64 len)
{
    80002530:	7179                	addi	sp,sp,-48
    80002532:	f406                	sd	ra,40(sp)
    80002534:	f022                	sd	s0,32(sp)
    80002536:	ec26                	sd	s1,24(sp)
    80002538:	e84a                	sd	s2,16(sp)
    8000253a:	e44e                	sd	s3,8(sp)
    8000253c:	e052                	sd	s4,0(sp)
    8000253e:	1800                	addi	s0,sp,48
    80002540:	892a                	mv	s2,a0
    80002542:	84ae                	mv	s1,a1
    80002544:	89b2                	mv	s3,a2
    80002546:	8a36                	mv	s4,a3
  struct proc *p = myproc();
    80002548:	fffff097          	auipc	ra,0xfffff
    8000254c:	4e2080e7          	jalr	1250(ra) # 80001a2a <myproc>
  if(user_src){
    80002550:	c08d                	beqz	s1,80002572 <either_copyin+0x42>
    return copyin(p->pagetable, dst, src, len);
    80002552:	86d2                	mv	a3,s4
    80002554:	864e                	mv	a2,s3
    80002556:	85ca                	mv	a1,s2
    80002558:	6928                	ld	a0,80(a0)
    8000255a:	fffff097          	auipc	ra,0xfffff
    8000255e:	218080e7          	jalr	536(ra) # 80001772 <copyin>
  } else {
    memmove(dst, (char*)src, len);
    return 0;
  }
}
    80002562:	70a2                	ld	ra,40(sp)
    80002564:	7402                	ld	s0,32(sp)
    80002566:	64e2                	ld	s1,24(sp)
    80002568:	6942                	ld	s2,16(sp)
    8000256a:	69a2                	ld	s3,8(sp)
    8000256c:	6a02                	ld	s4,0(sp)
    8000256e:	6145                	addi	sp,sp,48
    80002570:	8082                	ret
    memmove(dst, (char*)src, len);
    80002572:	000a061b          	sext.w	a2,s4
    80002576:	85ce                	mv	a1,s3
    80002578:	854a                	mv	a0,s2
    8000257a:	fffff097          	auipc	ra,0xfffff
    8000257e:	818080e7          	jalr	-2024(ra) # 80000d92 <memmove>
    return 0;
    80002582:	8526                	mv	a0,s1
    80002584:	bff9                	j	80002562 <either_copyin+0x32>

0000000080002586 <procdump>:
// Print a process listing to console.  For debugging.
// Runs when user types ^P on console.
// No lock to avoid wedging a stuck machine further.
void
procdump(void)
{
    80002586:	715d                	addi	sp,sp,-80
    80002588:	e486                	sd	ra,72(sp)
    8000258a:	e0a2                	sd	s0,64(sp)
    8000258c:	fc26                	sd	s1,56(sp)
    8000258e:	f84a                	sd	s2,48(sp)
    80002590:	f44e                	sd	s3,40(sp)
    80002592:	f052                	sd	s4,32(sp)
    80002594:	ec56                	sd	s5,24(sp)
    80002596:	e85a                	sd	s6,16(sp)
    80002598:	e45e                	sd	s7,8(sp)
    8000259a:	0880                	addi	s0,sp,80
  [ZOMBIE]    "zombie"
  };
  struct proc *p;
  char *state;

  printf("\n");
    8000259c:	00006517          	auipc	a0,0x6
    800025a0:	b6450513          	addi	a0,a0,-1180 # 80008100 <digits+0xc0>
    800025a4:	ffffe097          	auipc	ra,0xffffe
    800025a8:	fe4080e7          	jalr	-28(ra) # 80000588 <printf>
  for(p = proc; p < &proc[NPROC]; p++){
    800025ac:	0000f497          	auipc	s1,0xf
    800025b0:	b4c48493          	addi	s1,s1,-1204 # 800110f8 <proc+0x158>
    800025b4:	00014917          	auipc	s2,0x14
    800025b8:	54490913          	addi	s2,s2,1348 # 80016af8 <bcache+0x140>
    if(p->state == UNUSED)
      continue;
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    800025bc:	4b15                	li	s6,5
      state = states[p->state];
    else
      state = "???";
    800025be:	00006997          	auipc	s3,0x6
    800025c2:	cfa98993          	addi	s3,s3,-774 # 800082b8 <digits+0x278>
    printf("%d %s %s", p->pid, state, p->name);
    800025c6:	00006a97          	auipc	s5,0x6
    800025ca:	cfaa8a93          	addi	s5,s5,-774 # 800082c0 <digits+0x280>
    printf("\n");
    800025ce:	00006a17          	auipc	s4,0x6
    800025d2:	b32a0a13          	addi	s4,s4,-1230 # 80008100 <digits+0xc0>
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    800025d6:	00006b97          	auipc	s7,0x6
    800025da:	d2ab8b93          	addi	s7,s7,-726 # 80008300 <states.0>
    800025de:	a00d                	j	80002600 <procdump+0x7a>
    printf("%d %s %s", p->pid, state, p->name);
    800025e0:	ed86a583          	lw	a1,-296(a3)
    800025e4:	8556                	mv	a0,s5
    800025e6:	ffffe097          	auipc	ra,0xffffe
    800025ea:	fa2080e7          	jalr	-94(ra) # 80000588 <printf>
    printf("\n");
    800025ee:	8552                	mv	a0,s4
    800025f0:	ffffe097          	auipc	ra,0xffffe
    800025f4:	f98080e7          	jalr	-104(ra) # 80000588 <printf>
  for(p = proc; p < &proc[NPROC]; p++){
    800025f8:	16848493          	addi	s1,s1,360
    800025fc:	03248163          	beq	s1,s2,8000261e <procdump+0x98>
    if(p->state == UNUSED)
    80002600:	86a6                	mv	a3,s1
    80002602:	ec04a783          	lw	a5,-320(s1)
    80002606:	dbed                	beqz	a5,800025f8 <procdump+0x72>
      state = "???";
    80002608:	864e                	mv	a2,s3
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    8000260a:	fcfb6be3          	bltu	s6,a5,800025e0 <procdump+0x5a>
    8000260e:	1782                	slli	a5,a5,0x20
    80002610:	9381                	srli	a5,a5,0x20
    80002612:	078e                	slli	a5,a5,0x3
    80002614:	97de                	add	a5,a5,s7
    80002616:	6390                	ld	a2,0(a5)
    80002618:	f661                	bnez	a2,800025e0 <procdump+0x5a>
      state = "???";
    8000261a:	864e                	mv	a2,s3
    8000261c:	b7d1                	j	800025e0 <procdump+0x5a>
  }
}
    8000261e:	60a6                	ld	ra,72(sp)
    80002620:	6406                	ld	s0,64(sp)
    80002622:	74e2                	ld	s1,56(sp)
    80002624:	7942                	ld	s2,48(sp)
    80002626:	79a2                	ld	s3,40(sp)
    80002628:	7a02                	ld	s4,32(sp)
    8000262a:	6ae2                	ld	s5,24(sp)
    8000262c:	6b42                	ld	s6,16(sp)
    8000262e:	6ba2                	ld	s7,8(sp)
    80002630:	6161                	addi	sp,sp,80
    80002632:	8082                	ret

0000000080002634 <swtch>:
    80002634:	00153023          	sd	ra,0(a0)
    80002638:	00253423          	sd	sp,8(a0)
    8000263c:	e900                	sd	s0,16(a0)
    8000263e:	ed04                	sd	s1,24(a0)
    80002640:	03253023          	sd	s2,32(a0)
    80002644:	03353423          	sd	s3,40(a0)
    80002648:	03453823          	sd	s4,48(a0)
    8000264c:	03553c23          	sd	s5,56(a0)
    80002650:	05653023          	sd	s6,64(a0)
    80002654:	05753423          	sd	s7,72(a0)
    80002658:	05853823          	sd	s8,80(a0)
    8000265c:	05953c23          	sd	s9,88(a0)
    80002660:	07a53023          	sd	s10,96(a0)
    80002664:	07b53423          	sd	s11,104(a0)
    80002668:	0005b083          	ld	ra,0(a1)
    8000266c:	0085b103          	ld	sp,8(a1)
    80002670:	6980                	ld	s0,16(a1)
    80002672:	6d84                	ld	s1,24(a1)
    80002674:	0205b903          	ld	s2,32(a1)
    80002678:	0285b983          	ld	s3,40(a1)
    8000267c:	0305ba03          	ld	s4,48(a1)
    80002680:	0385ba83          	ld	s5,56(a1)
    80002684:	0405bb03          	ld	s6,64(a1)
    80002688:	0485bb83          	ld	s7,72(a1)
    8000268c:	0505bc03          	ld	s8,80(a1)
    80002690:	0585bc83          	ld	s9,88(a1)
    80002694:	0605bd03          	ld	s10,96(a1)
    80002698:	0685bd83          	ld	s11,104(a1)
    8000269c:	8082                	ret

000000008000269e <trapinit>:

extern int devintr();

void
trapinit(void)
{
    8000269e:	1141                	addi	sp,sp,-16
    800026a0:	e406                	sd	ra,8(sp)
    800026a2:	e022                	sd	s0,0(sp)
    800026a4:	0800                	addi	s0,sp,16
  initlock(&tickslock, "time");
    800026a6:	00006597          	auipc	a1,0x6
    800026aa:	c8a58593          	addi	a1,a1,-886 # 80008330 <states.0+0x30>
    800026ae:	00014517          	auipc	a0,0x14
    800026b2:	2f250513          	addi	a0,a0,754 # 800169a0 <tickslock>
    800026b6:	ffffe097          	auipc	ra,0xffffe
    800026ba:	4f4080e7          	jalr	1268(ra) # 80000baa <initlock>
}
    800026be:	60a2                	ld	ra,8(sp)
    800026c0:	6402                	ld	s0,0(sp)
    800026c2:	0141                	addi	sp,sp,16
    800026c4:	8082                	ret

00000000800026c6 <trapinithart>:

// set up to take exceptions and traps while in the kernel.
void
trapinithart(void)
{
    800026c6:	1141                	addi	sp,sp,-16
    800026c8:	e422                	sd	s0,8(sp)
    800026ca:	0800                	addi	s0,sp,16
  asm volatile("csrw stvec, %0" : : "r" (x));
    800026cc:	00003797          	auipc	a5,0x3
    800026d0:	4d478793          	addi	a5,a5,1236 # 80005ba0 <kernelvec>
    800026d4:	10579073          	csrw	stvec,a5
  w_stvec((uint64)kernelvec);
}
    800026d8:	6422                	ld	s0,8(sp)
    800026da:	0141                	addi	sp,sp,16
    800026dc:	8082                	ret

00000000800026de <usertrapret>:
//
// return to user space
//
void
usertrapret(void)
{
    800026de:	1141                	addi	sp,sp,-16
    800026e0:	e406                	sd	ra,8(sp)
    800026e2:	e022                	sd	s0,0(sp)
    800026e4:	0800                	addi	s0,sp,16
  struct proc *p = myproc();
    800026e6:	fffff097          	auipc	ra,0xfffff
    800026ea:	344080e7          	jalr	836(ra) # 80001a2a <myproc>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    800026ee:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    800026f2:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sstatus, %0" : : "r" (x));
    800026f4:	10079073          	csrw	sstatus,a5
  // kerneltrap() to usertrap(), so turn off interrupts until
  // we're back in user space, where usertrap() is correct.
  intr_off();

  // send syscalls, interrupts, and exceptions to uservec in trampoline.S
  uint64 trampoline_uservec = TRAMPOLINE + (uservec - trampoline);
    800026f8:	00005617          	auipc	a2,0x5
    800026fc:	90860613          	addi	a2,a2,-1784 # 80007000 <_trampoline>
    80002700:	00005697          	auipc	a3,0x5
    80002704:	90068693          	addi	a3,a3,-1792 # 80007000 <_trampoline>
    80002708:	8e91                	sub	a3,a3,a2
    8000270a:	040007b7          	lui	a5,0x4000
    8000270e:	17fd                	addi	a5,a5,-1
    80002710:	07b2                	slli	a5,a5,0xc
    80002712:	96be                	add	a3,a3,a5
  asm volatile("csrw stvec, %0" : : "r" (x));
    80002714:	10569073          	csrw	stvec,a3
  w_stvec(trampoline_uservec);

  // set up trapframe values that uservec will need when
  // the process next traps into the kernel.
  p->trapframe->kernel_satp = r_satp();         // kernel page table
    80002718:	6d38                	ld	a4,88(a0)
  asm volatile("csrr %0, satp" : "=r" (x) );
    8000271a:	180026f3          	csrr	a3,satp
    8000271e:	e314                	sd	a3,0(a4)
  p->trapframe->kernel_sp = p->kstack + PGSIZE; // process's kernel stack
    80002720:	6d38                	ld	a4,88(a0)
    80002722:	6134                	ld	a3,64(a0)
    80002724:	6585                	lui	a1,0x1
    80002726:	96ae                	add	a3,a3,a1
    80002728:	e714                	sd	a3,8(a4)
  p->trapframe->kernel_trap = (uint64)usertrap;
    8000272a:	6d38                	ld	a4,88(a0)
    8000272c:	00000697          	auipc	a3,0x0
    80002730:	13068693          	addi	a3,a3,304 # 8000285c <usertrap>
    80002734:	eb14                	sd	a3,16(a4)
  p->trapframe->kernel_hartid = r_tp();         // hartid for cpuid()
    80002736:	6d38                	ld	a4,88(a0)
  asm volatile("mv %0, tp" : "=r" (x) );
    80002738:	8692                	mv	a3,tp
    8000273a:	f314                	sd	a3,32(a4)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    8000273c:	100026f3          	csrr	a3,sstatus
  // set up the registers that trampoline.S's sret will use
  // to get to user space.
  
  // set S Previous Privilege mode to User.
  unsigned long x = r_sstatus();
  x &= ~SSTATUS_SPP; // clear SPP to 0 for user mode
    80002740:	eff6f693          	andi	a3,a3,-257
  x |= SSTATUS_SPIE; // enable interrupts in user mode
    80002744:	0206e693          	ori	a3,a3,32
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002748:	10069073          	csrw	sstatus,a3
  w_sstatus(x);

  // set S Exception Program Counter to the saved user pc.
  w_sepc(p->trapframe->epc);
    8000274c:	6d38                	ld	a4,88(a0)
  asm volatile("csrw sepc, %0" : : "r" (x));
    8000274e:	6f18                	ld	a4,24(a4)
    80002750:	14171073          	csrw	sepc,a4

  // tell trampoline.S the user page table to switch to.
  uint64 satp = MAKE_SATP(p->pagetable);
    80002754:	6928                	ld	a0,80(a0)
    80002756:	8131                	srli	a0,a0,0xc

  // jump to userret in trampoline.S at the top of memory, which 
  // switches to the user page table, restores user registers,
  // and switches to user mode with sret.
  uint64 trampoline_userret = TRAMPOLINE + (userret - trampoline);
    80002758:	00005717          	auipc	a4,0x5
    8000275c:	94470713          	addi	a4,a4,-1724 # 8000709c <userret>
    80002760:	8f11                	sub	a4,a4,a2
    80002762:	97ba                	add	a5,a5,a4
  ((void (*)(uint64))trampoline_userret)(satp);
    80002764:	577d                	li	a4,-1
    80002766:	177e                	slli	a4,a4,0x3f
    80002768:	8d59                	or	a0,a0,a4
    8000276a:	9782                	jalr	a5
}
    8000276c:	60a2                	ld	ra,8(sp)
    8000276e:	6402                	ld	s0,0(sp)
    80002770:	0141                	addi	sp,sp,16
    80002772:	8082                	ret

0000000080002774 <clockintr>:
  w_sstatus(sstatus);
}

void
clockintr()
{
    80002774:	1101                	addi	sp,sp,-32
    80002776:	ec06                	sd	ra,24(sp)
    80002778:	e822                	sd	s0,16(sp)
    8000277a:	e426                	sd	s1,8(sp)
    8000277c:	1000                	addi	s0,sp,32
  acquire(&tickslock);
    8000277e:	00014497          	auipc	s1,0x14
    80002782:	22248493          	addi	s1,s1,546 # 800169a0 <tickslock>
    80002786:	8526                	mv	a0,s1
    80002788:	ffffe097          	auipc	ra,0xffffe
    8000278c:	4b2080e7          	jalr	1202(ra) # 80000c3a <acquire>
  ticks++;
    80002790:	00006517          	auipc	a0,0x6
    80002794:	17050513          	addi	a0,a0,368 # 80008900 <ticks>
    80002798:	411c                	lw	a5,0(a0)
    8000279a:	2785                	addiw	a5,a5,1
    8000279c:	c11c                	sw	a5,0(a0)
  wakeup(&ticks);
    8000279e:	00000097          	auipc	ra,0x0
    800027a2:	998080e7          	jalr	-1640(ra) # 80002136 <wakeup>
  release(&tickslock);
    800027a6:	8526                	mv	a0,s1
    800027a8:	ffffe097          	auipc	ra,0xffffe
    800027ac:	546080e7          	jalr	1350(ra) # 80000cee <release>
}
    800027b0:	60e2                	ld	ra,24(sp)
    800027b2:	6442                	ld	s0,16(sp)
    800027b4:	64a2                	ld	s1,8(sp)
    800027b6:	6105                	addi	sp,sp,32
    800027b8:	8082                	ret

00000000800027ba <devintr>:
// returns 2 if timer interrupt,
// 1 if other device,
// 0 if not recognized.
int
devintr()
{
    800027ba:	1101                	addi	sp,sp,-32
    800027bc:	ec06                	sd	ra,24(sp)
    800027be:	e822                	sd	s0,16(sp)
    800027c0:	e426                	sd	s1,8(sp)
    800027c2:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, scause" : "=r" (x) );
    800027c4:	14202773          	csrr	a4,scause
  uint64 scause = r_scause();

  if((scause & 0x8000000000000000L) &&
    800027c8:	00074d63          	bltz	a4,800027e2 <devintr+0x28>
    // now allowed to interrupt again.
    if(irq)
      plic_complete(irq);

    return 1;
  } else if(scause == 0x8000000000000001L){
    800027cc:	57fd                	li	a5,-1
    800027ce:	17fe                	slli	a5,a5,0x3f
    800027d0:	0785                	addi	a5,a5,1
    // the SSIP bit in sip.
    w_sip(r_sip() & ~2);

    return 2;
  } else {
    return 0;
    800027d2:	4501                	li	a0,0
  } else if(scause == 0x8000000000000001L){
    800027d4:	06f70363          	beq	a4,a5,8000283a <devintr+0x80>
  }
}
    800027d8:	60e2                	ld	ra,24(sp)
    800027da:	6442                	ld	s0,16(sp)
    800027dc:	64a2                	ld	s1,8(sp)
    800027de:	6105                	addi	sp,sp,32
    800027e0:	8082                	ret
     (scause & 0xff) == 9){
    800027e2:	0ff77793          	andi	a5,a4,255
  if((scause & 0x8000000000000000L) &&
    800027e6:	46a5                	li	a3,9
    800027e8:	fed792e3          	bne	a5,a3,800027cc <devintr+0x12>
    int irq = plic_claim();
    800027ec:	00003097          	auipc	ra,0x3
    800027f0:	4bc080e7          	jalr	1212(ra) # 80005ca8 <plic_claim>
    800027f4:	84aa                	mv	s1,a0
    if(irq == UART0_IRQ){
    800027f6:	47a9                	li	a5,10
    800027f8:	02f50763          	beq	a0,a5,80002826 <devintr+0x6c>
    } else if(irq == VIRTIO0_IRQ){
    800027fc:	4785                	li	a5,1
    800027fe:	02f50963          	beq	a0,a5,80002830 <devintr+0x76>
    return 1;
    80002802:	4505                	li	a0,1
    } else if(irq){
    80002804:	d8f1                	beqz	s1,800027d8 <devintr+0x1e>
      printf("unexpected interrupt irq=%d\n", irq);
    80002806:	85a6                	mv	a1,s1
    80002808:	00006517          	auipc	a0,0x6
    8000280c:	b3050513          	addi	a0,a0,-1232 # 80008338 <states.0+0x38>
    80002810:	ffffe097          	auipc	ra,0xffffe
    80002814:	d78080e7          	jalr	-648(ra) # 80000588 <printf>
      plic_complete(irq);
    80002818:	8526                	mv	a0,s1
    8000281a:	00003097          	auipc	ra,0x3
    8000281e:	4b2080e7          	jalr	1202(ra) # 80005ccc <plic_complete>
    return 1;
    80002822:	4505                	li	a0,1
    80002824:	bf55                	j	800027d8 <devintr+0x1e>
      uartintr();
    80002826:	ffffe097          	auipc	ra,0xffffe
    8000282a:	174080e7          	jalr	372(ra) # 8000099a <uartintr>
    8000282e:	b7ed                	j	80002818 <devintr+0x5e>
      virtio_disk_intr();
    80002830:	00004097          	auipc	ra,0x4
    80002834:	968080e7          	jalr	-1688(ra) # 80006198 <virtio_disk_intr>
    80002838:	b7c5                	j	80002818 <devintr+0x5e>
    if(cpuid() == 0){
    8000283a:	fffff097          	auipc	ra,0xfffff
    8000283e:	1c4080e7          	jalr	452(ra) # 800019fe <cpuid>
    80002842:	c901                	beqz	a0,80002852 <devintr+0x98>
  asm volatile("csrr %0, sip" : "=r" (x) );
    80002844:	144027f3          	csrr	a5,sip
    w_sip(r_sip() & ~2);
    80002848:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sip, %0" : : "r" (x));
    8000284a:	14479073          	csrw	sip,a5
    return 2;
    8000284e:	4509                	li	a0,2
    80002850:	b761                	j	800027d8 <devintr+0x1e>
      clockintr();
    80002852:	00000097          	auipc	ra,0x0
    80002856:	f22080e7          	jalr	-222(ra) # 80002774 <clockintr>
    8000285a:	b7ed                	j	80002844 <devintr+0x8a>

000000008000285c <usertrap>:
{
    8000285c:	1101                	addi	sp,sp,-32
    8000285e:	ec06                	sd	ra,24(sp)
    80002860:	e822                	sd	s0,16(sp)
    80002862:	e426                	sd	s1,8(sp)
    80002864:	e04a                	sd	s2,0(sp)
    80002866:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002868:	100027f3          	csrr	a5,sstatus
  if((r_sstatus() & SSTATUS_SPP) != 0)
    8000286c:	1007f793          	andi	a5,a5,256
    80002870:	e3b1                	bnez	a5,800028b4 <usertrap+0x58>
  asm volatile("csrw stvec, %0" : : "r" (x));
    80002872:	00003797          	auipc	a5,0x3
    80002876:	32e78793          	addi	a5,a5,814 # 80005ba0 <kernelvec>
    8000287a:	10579073          	csrw	stvec,a5
  struct proc *p = myproc();
    8000287e:	fffff097          	auipc	ra,0xfffff
    80002882:	1ac080e7          	jalr	428(ra) # 80001a2a <myproc>
    80002886:	84aa                	mv	s1,a0
  p->trapframe->epc = r_sepc();
    80002888:	6d3c                	ld	a5,88(a0)
  asm volatile("csrr %0, sepc" : "=r" (x) );
    8000288a:	14102773          	csrr	a4,sepc
    8000288e:	ef98                	sd	a4,24(a5)
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002890:	14202773          	csrr	a4,scause
  if(r_scause() == 8){
    80002894:	47a1                	li	a5,8
    80002896:	02f70763          	beq	a4,a5,800028c4 <usertrap+0x68>
  } else if((which_dev = devintr()) != 0){
    8000289a:	00000097          	auipc	ra,0x0
    8000289e:	f20080e7          	jalr	-224(ra) # 800027ba <devintr>
    800028a2:	892a                	mv	s2,a0
    800028a4:	c151                	beqz	a0,80002928 <usertrap+0xcc>
  if(killed(p))
    800028a6:	8526                	mv	a0,s1
    800028a8:	00000097          	auipc	ra,0x0
    800028ac:	ad2080e7          	jalr	-1326(ra) # 8000237a <killed>
    800028b0:	c929                	beqz	a0,80002902 <usertrap+0xa6>
    800028b2:	a099                	j	800028f8 <usertrap+0x9c>
    panic("usertrap: not from user mode");
    800028b4:	00006517          	auipc	a0,0x6
    800028b8:	aa450513          	addi	a0,a0,-1372 # 80008358 <states.0+0x58>
    800028bc:	ffffe097          	auipc	ra,0xffffe
    800028c0:	c82080e7          	jalr	-894(ra) # 8000053e <panic>
    if(killed(p))
    800028c4:	00000097          	auipc	ra,0x0
    800028c8:	ab6080e7          	jalr	-1354(ra) # 8000237a <killed>
    800028cc:	e921                	bnez	a0,8000291c <usertrap+0xc0>
    p->trapframe->epc += 4;
    800028ce:	6cb8                	ld	a4,88(s1)
    800028d0:	6f1c                	ld	a5,24(a4)
    800028d2:	0791                	addi	a5,a5,4
    800028d4:	ef1c                	sd	a5,24(a4)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    800028d6:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    800028da:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    800028de:	10079073          	csrw	sstatus,a5
    syscall();
    800028e2:	00000097          	auipc	ra,0x0
    800028e6:	2d4080e7          	jalr	724(ra) # 80002bb6 <syscall>
  if(killed(p))
    800028ea:	8526                	mv	a0,s1
    800028ec:	00000097          	auipc	ra,0x0
    800028f0:	a8e080e7          	jalr	-1394(ra) # 8000237a <killed>
    800028f4:	c911                	beqz	a0,80002908 <usertrap+0xac>
    800028f6:	4901                	li	s2,0
    exit(-1);
    800028f8:	557d                	li	a0,-1
    800028fa:	00000097          	auipc	ra,0x0
    800028fe:	90c080e7          	jalr	-1780(ra) # 80002206 <exit>
  if(which_dev == 2)
    80002902:	4789                	li	a5,2
    80002904:	04f90f63          	beq	s2,a5,80002962 <usertrap+0x106>
  usertrapret();
    80002908:	00000097          	auipc	ra,0x0
    8000290c:	dd6080e7          	jalr	-554(ra) # 800026de <usertrapret>
}
    80002910:	60e2                	ld	ra,24(sp)
    80002912:	6442                	ld	s0,16(sp)
    80002914:	64a2                	ld	s1,8(sp)
    80002916:	6902                	ld	s2,0(sp)
    80002918:	6105                	addi	sp,sp,32
    8000291a:	8082                	ret
      exit(-1);
    8000291c:	557d                	li	a0,-1
    8000291e:	00000097          	auipc	ra,0x0
    80002922:	8e8080e7          	jalr	-1816(ra) # 80002206 <exit>
    80002926:	b765                	j	800028ce <usertrap+0x72>
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002928:	142025f3          	csrr	a1,scause
    printf("usertrap(): unexpected scause %p pid=%d\n", r_scause(), p->pid);
    8000292c:	5890                	lw	a2,48(s1)
    8000292e:	00006517          	auipc	a0,0x6
    80002932:	a4a50513          	addi	a0,a0,-1462 # 80008378 <states.0+0x78>
    80002936:	ffffe097          	auipc	ra,0xffffe
    8000293a:	c52080e7          	jalr	-942(ra) # 80000588 <printf>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    8000293e:	141025f3          	csrr	a1,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    80002942:	14302673          	csrr	a2,stval
    printf("            sepc=%p stval=%p\n", r_sepc(), r_stval());
    80002946:	00006517          	auipc	a0,0x6
    8000294a:	a6250513          	addi	a0,a0,-1438 # 800083a8 <states.0+0xa8>
    8000294e:	ffffe097          	auipc	ra,0xffffe
    80002952:	c3a080e7          	jalr	-966(ra) # 80000588 <printf>
    setkilled(p);
    80002956:	8526                	mv	a0,s1
    80002958:	00000097          	auipc	ra,0x0
    8000295c:	9f6080e7          	jalr	-1546(ra) # 8000234e <setkilled>
    80002960:	b769                	j	800028ea <usertrap+0x8e>
    yield();
    80002962:	fffff097          	auipc	ra,0xfffff
    80002966:	734080e7          	jalr	1844(ra) # 80002096 <yield>
    8000296a:	bf79                	j	80002908 <usertrap+0xac>

000000008000296c <kerneltrap>:
{
    8000296c:	7179                	addi	sp,sp,-48
    8000296e:	f406                	sd	ra,40(sp)
    80002970:	f022                	sd	s0,32(sp)
    80002972:	ec26                	sd	s1,24(sp)
    80002974:	e84a                	sd	s2,16(sp)
    80002976:	e44e                	sd	s3,8(sp)
    80002978:	1800                	addi	s0,sp,48
  asm volatile("csrr %0, sepc" : "=r" (x) );
    8000297a:	14102973          	csrr	s2,sepc
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    8000297e:	100024f3          	csrr	s1,sstatus
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002982:	142029f3          	csrr	s3,scause
  if((sstatus & SSTATUS_SPP) == 0)
    80002986:	1004f793          	andi	a5,s1,256
    8000298a:	cb85                	beqz	a5,800029ba <kerneltrap+0x4e>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    8000298c:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80002990:	8b89                	andi	a5,a5,2
  if(intr_get() != 0)
    80002992:	ef85                	bnez	a5,800029ca <kerneltrap+0x5e>
  if((which_dev = devintr()) == 0){
    80002994:	00000097          	auipc	ra,0x0
    80002998:	e26080e7          	jalr	-474(ra) # 800027ba <devintr>
    8000299c:	cd1d                	beqz	a0,800029da <kerneltrap+0x6e>
  if(which_dev == 2 && myproc() != 0 && myproc()->state == RUNNING)
    8000299e:	4789                	li	a5,2
    800029a0:	06f50a63          	beq	a0,a5,80002a14 <kerneltrap+0xa8>
  asm volatile("csrw sepc, %0" : : "r" (x));
    800029a4:	14191073          	csrw	sepc,s2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    800029a8:	10049073          	csrw	sstatus,s1
}
    800029ac:	70a2                	ld	ra,40(sp)
    800029ae:	7402                	ld	s0,32(sp)
    800029b0:	64e2                	ld	s1,24(sp)
    800029b2:	6942                	ld	s2,16(sp)
    800029b4:	69a2                	ld	s3,8(sp)
    800029b6:	6145                	addi	sp,sp,48
    800029b8:	8082                	ret
    panic("kerneltrap: not from supervisor mode");
    800029ba:	00006517          	auipc	a0,0x6
    800029be:	a0e50513          	addi	a0,a0,-1522 # 800083c8 <states.0+0xc8>
    800029c2:	ffffe097          	auipc	ra,0xffffe
    800029c6:	b7c080e7          	jalr	-1156(ra) # 8000053e <panic>
    panic("kerneltrap: interrupts enabled");
    800029ca:	00006517          	auipc	a0,0x6
    800029ce:	a2650513          	addi	a0,a0,-1498 # 800083f0 <states.0+0xf0>
    800029d2:	ffffe097          	auipc	ra,0xffffe
    800029d6:	b6c080e7          	jalr	-1172(ra) # 8000053e <panic>
    printf("scause %p\n", scause);
    800029da:	85ce                	mv	a1,s3
    800029dc:	00006517          	auipc	a0,0x6
    800029e0:	a3450513          	addi	a0,a0,-1484 # 80008410 <states.0+0x110>
    800029e4:	ffffe097          	auipc	ra,0xffffe
    800029e8:	ba4080e7          	jalr	-1116(ra) # 80000588 <printf>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    800029ec:	141025f3          	csrr	a1,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    800029f0:	14302673          	csrr	a2,stval
    printf("sepc=%p stval=%p\n", r_sepc(), r_stval());
    800029f4:	00006517          	auipc	a0,0x6
    800029f8:	a2c50513          	addi	a0,a0,-1492 # 80008420 <states.0+0x120>
    800029fc:	ffffe097          	auipc	ra,0xffffe
    80002a00:	b8c080e7          	jalr	-1140(ra) # 80000588 <printf>
    panic("kerneltrap");
    80002a04:	00006517          	auipc	a0,0x6
    80002a08:	a3450513          	addi	a0,a0,-1484 # 80008438 <states.0+0x138>
    80002a0c:	ffffe097          	auipc	ra,0xffffe
    80002a10:	b32080e7          	jalr	-1230(ra) # 8000053e <panic>
  if(which_dev == 2 && myproc() != 0 && myproc()->state == RUNNING)
    80002a14:	fffff097          	auipc	ra,0xfffff
    80002a18:	016080e7          	jalr	22(ra) # 80001a2a <myproc>
    80002a1c:	d541                	beqz	a0,800029a4 <kerneltrap+0x38>
    80002a1e:	fffff097          	auipc	ra,0xfffff
    80002a22:	00c080e7          	jalr	12(ra) # 80001a2a <myproc>
    80002a26:	4d18                	lw	a4,24(a0)
    80002a28:	4791                	li	a5,4
    80002a2a:	f6f71de3          	bne	a4,a5,800029a4 <kerneltrap+0x38>
    yield();
    80002a2e:	fffff097          	auipc	ra,0xfffff
    80002a32:	668080e7          	jalr	1640(ra) # 80002096 <yield>
    80002a36:	b7bd                	j	800029a4 <kerneltrap+0x38>

0000000080002a38 <argraw>:
  return strlen(buf);
}

static uint64
argraw(int n)
{
    80002a38:	1101                	addi	sp,sp,-32
    80002a3a:	ec06                	sd	ra,24(sp)
    80002a3c:	e822                	sd	s0,16(sp)
    80002a3e:	e426                	sd	s1,8(sp)
    80002a40:	1000                	addi	s0,sp,32
    80002a42:	84aa                	mv	s1,a0
  struct proc *p = myproc();
    80002a44:	fffff097          	auipc	ra,0xfffff
    80002a48:	fe6080e7          	jalr	-26(ra) # 80001a2a <myproc>
  switch (n) {
    80002a4c:	4795                	li	a5,5
    80002a4e:	0497e163          	bltu	a5,s1,80002a90 <argraw+0x58>
    80002a52:	048a                	slli	s1,s1,0x2
    80002a54:	00006717          	auipc	a4,0x6
    80002a58:	a1c70713          	addi	a4,a4,-1508 # 80008470 <states.0+0x170>
    80002a5c:	94ba                	add	s1,s1,a4
    80002a5e:	409c                	lw	a5,0(s1)
    80002a60:	97ba                	add	a5,a5,a4
    80002a62:	8782                	jr	a5
  case 0:
    return p->trapframe->a0;
    80002a64:	6d3c                	ld	a5,88(a0)
    80002a66:	7ba8                	ld	a0,112(a5)
  case 5:
    return p->trapframe->a5;
  }
  panic("argraw");
  return -1;
}
    80002a68:	60e2                	ld	ra,24(sp)
    80002a6a:	6442                	ld	s0,16(sp)
    80002a6c:	64a2                	ld	s1,8(sp)
    80002a6e:	6105                	addi	sp,sp,32
    80002a70:	8082                	ret
    return p->trapframe->a1;
    80002a72:	6d3c                	ld	a5,88(a0)
    80002a74:	7fa8                	ld	a0,120(a5)
    80002a76:	bfcd                	j	80002a68 <argraw+0x30>
    return p->trapframe->a2;
    80002a78:	6d3c                	ld	a5,88(a0)
    80002a7a:	63c8                	ld	a0,128(a5)
    80002a7c:	b7f5                	j	80002a68 <argraw+0x30>
    return p->trapframe->a3;
    80002a7e:	6d3c                	ld	a5,88(a0)
    80002a80:	67c8                	ld	a0,136(a5)
    80002a82:	b7dd                	j	80002a68 <argraw+0x30>
    return p->trapframe->a4;
    80002a84:	6d3c                	ld	a5,88(a0)
    80002a86:	6bc8                	ld	a0,144(a5)
    80002a88:	b7c5                	j	80002a68 <argraw+0x30>
    return p->trapframe->a5;
    80002a8a:	6d3c                	ld	a5,88(a0)
    80002a8c:	6fc8                	ld	a0,152(a5)
    80002a8e:	bfe9                	j	80002a68 <argraw+0x30>
  panic("argraw");
    80002a90:	00006517          	auipc	a0,0x6
    80002a94:	9b850513          	addi	a0,a0,-1608 # 80008448 <states.0+0x148>
    80002a98:	ffffe097          	auipc	ra,0xffffe
    80002a9c:	aa6080e7          	jalr	-1370(ra) # 8000053e <panic>

0000000080002aa0 <fetchaddr>:
{
    80002aa0:	1101                	addi	sp,sp,-32
    80002aa2:	ec06                	sd	ra,24(sp)
    80002aa4:	e822                	sd	s0,16(sp)
    80002aa6:	e426                	sd	s1,8(sp)
    80002aa8:	e04a                	sd	s2,0(sp)
    80002aaa:	1000                	addi	s0,sp,32
    80002aac:	84aa                	mv	s1,a0
    80002aae:	892e                	mv	s2,a1
  struct proc *p = myproc();
    80002ab0:	fffff097          	auipc	ra,0xfffff
    80002ab4:	f7a080e7          	jalr	-134(ra) # 80001a2a <myproc>
  if(addr >= p->sz || addr+sizeof(uint64) > p->sz) // both tests needed, in case of overflow
    80002ab8:	653c                	ld	a5,72(a0)
    80002aba:	02f4f863          	bgeu	s1,a5,80002aea <fetchaddr+0x4a>
    80002abe:	00848713          	addi	a4,s1,8
    80002ac2:	02e7e663          	bltu	a5,a4,80002aee <fetchaddr+0x4e>
  if(copyin(p->pagetable, (char *)ip, addr, sizeof(*ip)) != 0)
    80002ac6:	46a1                	li	a3,8
    80002ac8:	8626                	mv	a2,s1
    80002aca:	85ca                	mv	a1,s2
    80002acc:	6928                	ld	a0,80(a0)
    80002ace:	fffff097          	auipc	ra,0xfffff
    80002ad2:	ca4080e7          	jalr	-860(ra) # 80001772 <copyin>
    80002ad6:	00a03533          	snez	a0,a0
    80002ada:	40a00533          	neg	a0,a0
}
    80002ade:	60e2                	ld	ra,24(sp)
    80002ae0:	6442                	ld	s0,16(sp)
    80002ae2:	64a2                	ld	s1,8(sp)
    80002ae4:	6902                	ld	s2,0(sp)
    80002ae6:	6105                	addi	sp,sp,32
    80002ae8:	8082                	ret
    return -1;
    80002aea:	557d                	li	a0,-1
    80002aec:	bfcd                	j	80002ade <fetchaddr+0x3e>
    80002aee:	557d                	li	a0,-1
    80002af0:	b7fd                	j	80002ade <fetchaddr+0x3e>

0000000080002af2 <fetchstr>:
{
    80002af2:	7179                	addi	sp,sp,-48
    80002af4:	f406                	sd	ra,40(sp)
    80002af6:	f022                	sd	s0,32(sp)
    80002af8:	ec26                	sd	s1,24(sp)
    80002afa:	e84a                	sd	s2,16(sp)
    80002afc:	e44e                	sd	s3,8(sp)
    80002afe:	1800                	addi	s0,sp,48
    80002b00:	892a                	mv	s2,a0
    80002b02:	84ae                	mv	s1,a1
    80002b04:	89b2                	mv	s3,a2
  struct proc *p = myproc();
    80002b06:	fffff097          	auipc	ra,0xfffff
    80002b0a:	f24080e7          	jalr	-220(ra) # 80001a2a <myproc>
  if(copyinstr(p->pagetable, buf, addr, max) < 0)
    80002b0e:	86ce                	mv	a3,s3
    80002b10:	864a                	mv	a2,s2
    80002b12:	85a6                	mv	a1,s1
    80002b14:	6928                	ld	a0,80(a0)
    80002b16:	fffff097          	auipc	ra,0xfffff
    80002b1a:	cea080e7          	jalr	-790(ra) # 80001800 <copyinstr>
    80002b1e:	00054e63          	bltz	a0,80002b3a <fetchstr+0x48>
  return strlen(buf);
    80002b22:	8526                	mv	a0,s1
    80002b24:	ffffe097          	auipc	ra,0xffffe
    80002b28:	38e080e7          	jalr	910(ra) # 80000eb2 <strlen>
}
    80002b2c:	70a2                	ld	ra,40(sp)
    80002b2e:	7402                	ld	s0,32(sp)
    80002b30:	64e2                	ld	s1,24(sp)
    80002b32:	6942                	ld	s2,16(sp)
    80002b34:	69a2                	ld	s3,8(sp)
    80002b36:	6145                	addi	sp,sp,48
    80002b38:	8082                	ret
    return -1;
    80002b3a:	557d                	li	a0,-1
    80002b3c:	bfc5                	j	80002b2c <fetchstr+0x3a>

0000000080002b3e <argint>:

// Fetch the nth 32-bit system call argument.
void
argint(int n, int *ip)
{
    80002b3e:	1101                	addi	sp,sp,-32
    80002b40:	ec06                	sd	ra,24(sp)
    80002b42:	e822                	sd	s0,16(sp)
    80002b44:	e426                	sd	s1,8(sp)
    80002b46:	1000                	addi	s0,sp,32
    80002b48:	84ae                	mv	s1,a1
  *ip = argraw(n);
    80002b4a:	00000097          	auipc	ra,0x0
    80002b4e:	eee080e7          	jalr	-274(ra) # 80002a38 <argraw>
    80002b52:	c088                	sw	a0,0(s1)
}
    80002b54:	60e2                	ld	ra,24(sp)
    80002b56:	6442                	ld	s0,16(sp)
    80002b58:	64a2                	ld	s1,8(sp)
    80002b5a:	6105                	addi	sp,sp,32
    80002b5c:	8082                	ret

0000000080002b5e <argaddr>:
// Retrieve an argument as a pointer.
// Doesn't check for legality, since
// copyin/copyout will do that.
void
argaddr(int n, uint64 *ip)
{
    80002b5e:	1101                	addi	sp,sp,-32
    80002b60:	ec06                	sd	ra,24(sp)
    80002b62:	e822                	sd	s0,16(sp)
    80002b64:	e426                	sd	s1,8(sp)
    80002b66:	1000                	addi	s0,sp,32
    80002b68:	84ae                	mv	s1,a1
  *ip = argraw(n);
    80002b6a:	00000097          	auipc	ra,0x0
    80002b6e:	ece080e7          	jalr	-306(ra) # 80002a38 <argraw>
    80002b72:	e088                	sd	a0,0(s1)
}
    80002b74:	60e2                	ld	ra,24(sp)
    80002b76:	6442                	ld	s0,16(sp)
    80002b78:	64a2                	ld	s1,8(sp)
    80002b7a:	6105                	addi	sp,sp,32
    80002b7c:	8082                	ret

0000000080002b7e <argstr>:
// Fetch the nth word-sized system call argument as a null-terminated string.
// Copies into buf, at most max.
// Returns string length if OK (including nul), -1 if error.
int
argstr(int n, char *buf, int max)
{
    80002b7e:	7179                	addi	sp,sp,-48
    80002b80:	f406                	sd	ra,40(sp)
    80002b82:	f022                	sd	s0,32(sp)
    80002b84:	ec26                	sd	s1,24(sp)
    80002b86:	e84a                	sd	s2,16(sp)
    80002b88:	1800                	addi	s0,sp,48
    80002b8a:	84ae                	mv	s1,a1
    80002b8c:	8932                	mv	s2,a2
  uint64 addr;
  argaddr(n, &addr);
    80002b8e:	fd840593          	addi	a1,s0,-40
    80002b92:	00000097          	auipc	ra,0x0
    80002b96:	fcc080e7          	jalr	-52(ra) # 80002b5e <argaddr>
  return fetchstr(addr, buf, max);
    80002b9a:	864a                	mv	a2,s2
    80002b9c:	85a6                	mv	a1,s1
    80002b9e:	fd843503          	ld	a0,-40(s0)
    80002ba2:	00000097          	auipc	ra,0x0
    80002ba6:	f50080e7          	jalr	-176(ra) # 80002af2 <fetchstr>
}
    80002baa:	70a2                	ld	ra,40(sp)
    80002bac:	7402                	ld	s0,32(sp)
    80002bae:	64e2                	ld	s1,24(sp)
    80002bb0:	6942                	ld	s2,16(sp)
    80002bb2:	6145                	addi	sp,sp,48
    80002bb4:	8082                	ret

0000000080002bb6 <syscall>:
[SYS_kfreemem]sys_kfreemem,
};

void
syscall(void)
{
    80002bb6:	1101                	addi	sp,sp,-32
    80002bb8:	ec06                	sd	ra,24(sp)
    80002bba:	e822                	sd	s0,16(sp)
    80002bbc:	e426                	sd	s1,8(sp)
    80002bbe:	e04a                	sd	s2,0(sp)
    80002bc0:	1000                	addi	s0,sp,32
  int num;
  struct proc *p = myproc();
    80002bc2:	fffff097          	auipc	ra,0xfffff
    80002bc6:	e68080e7          	jalr	-408(ra) # 80001a2a <myproc>
    80002bca:	84aa                	mv	s1,a0

  num = p->trapframe->a7;
    80002bcc:	05853903          	ld	s2,88(a0)
    80002bd0:	0a893783          	ld	a5,168(s2)
    80002bd4:	0007869b          	sext.w	a3,a5
  if(num > 0 && num < NELEM(syscalls) && syscalls[num]) {
    80002bd8:	37fd                	addiw	a5,a5,-1
    80002bda:	4755                	li	a4,21
    80002bdc:	00f76f63          	bltu	a4,a5,80002bfa <syscall+0x44>
    80002be0:	00369713          	slli	a4,a3,0x3
    80002be4:	00006797          	auipc	a5,0x6
    80002be8:	8a478793          	addi	a5,a5,-1884 # 80008488 <syscalls>
    80002bec:	97ba                	add	a5,a5,a4
    80002bee:	639c                	ld	a5,0(a5)
    80002bf0:	c789                	beqz	a5,80002bfa <syscall+0x44>
    // Use num to lookup the system call function for num, call it,
    // and store its return value in p->trapframe->a0
    p->trapframe->a0 = syscalls[num]();
    80002bf2:	9782                	jalr	a5
    80002bf4:	06a93823          	sd	a0,112(s2)
    80002bf8:	a839                	j	80002c16 <syscall+0x60>
  } else {
    printf("%d %s: unknown sys call %d\n",
    80002bfa:	15848613          	addi	a2,s1,344
    80002bfe:	588c                	lw	a1,48(s1)
    80002c00:	00006517          	auipc	a0,0x6
    80002c04:	85050513          	addi	a0,a0,-1968 # 80008450 <states.0+0x150>
    80002c08:	ffffe097          	auipc	ra,0xffffe
    80002c0c:	980080e7          	jalr	-1664(ra) # 80000588 <printf>
            p->pid, p->name, num);
    p->trapframe->a0 = -1;
    80002c10:	6cbc                	ld	a5,88(s1)
    80002c12:	577d                	li	a4,-1
    80002c14:	fbb8                	sd	a4,112(a5)
  }
}
    80002c16:	60e2                	ld	ra,24(sp)
    80002c18:	6442                	ld	s0,16(sp)
    80002c1a:	64a2                	ld	s1,8(sp)
    80002c1c:	6902                	ld	s2,0(sp)
    80002c1e:	6105                	addi	sp,sp,32
    80002c20:	8082                	ret

0000000080002c22 <sys_exit>:
#include "spinlock.h"
#include "proc.h"

uint64
sys_exit(void)
{
    80002c22:	1101                	addi	sp,sp,-32
    80002c24:	ec06                	sd	ra,24(sp)
    80002c26:	e822                	sd	s0,16(sp)
    80002c28:	1000                	addi	s0,sp,32
  int n;
  argint(0, &n);
    80002c2a:	fec40593          	addi	a1,s0,-20
    80002c2e:	4501                	li	a0,0
    80002c30:	00000097          	auipc	ra,0x0
    80002c34:	f0e080e7          	jalr	-242(ra) # 80002b3e <argint>
  exit(n);
    80002c38:	fec42503          	lw	a0,-20(s0)
    80002c3c:	fffff097          	auipc	ra,0xfffff
    80002c40:	5ca080e7          	jalr	1482(ra) # 80002206 <exit>
  return 0;  // not reached
}
    80002c44:	4501                	li	a0,0
    80002c46:	60e2                	ld	ra,24(sp)
    80002c48:	6442                	ld	s0,16(sp)
    80002c4a:	6105                	addi	sp,sp,32
    80002c4c:	8082                	ret

0000000080002c4e <sys_getpid>:

uint64
sys_getpid(void)
{
    80002c4e:	1141                	addi	sp,sp,-16
    80002c50:	e406                	sd	ra,8(sp)
    80002c52:	e022                	sd	s0,0(sp)
    80002c54:	0800                	addi	s0,sp,16
  return myproc()->pid;
    80002c56:	fffff097          	auipc	ra,0xfffff
    80002c5a:	dd4080e7          	jalr	-556(ra) # 80001a2a <myproc>
}
    80002c5e:	5908                	lw	a0,48(a0)
    80002c60:	60a2                	ld	ra,8(sp)
    80002c62:	6402                	ld	s0,0(sp)
    80002c64:	0141                	addi	sp,sp,16
    80002c66:	8082                	ret

0000000080002c68 <sys_fork>:

uint64
sys_fork(void)
{
    80002c68:	1141                	addi	sp,sp,-16
    80002c6a:	e406                	sd	ra,8(sp)
    80002c6c:	e022                	sd	s0,0(sp)
    80002c6e:	0800                	addi	s0,sp,16
  return fork();
    80002c70:	fffff097          	auipc	ra,0xfffff
    80002c74:	170080e7          	jalr	368(ra) # 80001de0 <fork>
}
    80002c78:	60a2                	ld	ra,8(sp)
    80002c7a:	6402                	ld	s0,0(sp)
    80002c7c:	0141                	addi	sp,sp,16
    80002c7e:	8082                	ret

0000000080002c80 <sys_wait>:

uint64
sys_wait(void)
{
    80002c80:	1101                	addi	sp,sp,-32
    80002c82:	ec06                	sd	ra,24(sp)
    80002c84:	e822                	sd	s0,16(sp)
    80002c86:	1000                	addi	s0,sp,32
  uint64 p;
  argaddr(0, &p);
    80002c88:	fe840593          	addi	a1,s0,-24
    80002c8c:	4501                	li	a0,0
    80002c8e:	00000097          	auipc	ra,0x0
    80002c92:	ed0080e7          	jalr	-304(ra) # 80002b5e <argaddr>
  return wait(p);
    80002c96:	fe843503          	ld	a0,-24(s0)
    80002c9a:	fffff097          	auipc	ra,0xfffff
    80002c9e:	712080e7          	jalr	1810(ra) # 800023ac <wait>
}
    80002ca2:	60e2                	ld	ra,24(sp)
    80002ca4:	6442                	ld	s0,16(sp)
    80002ca6:	6105                	addi	sp,sp,32
    80002ca8:	8082                	ret

0000000080002caa <sys_sbrk>:

uint64
sys_sbrk(void)
{
    80002caa:	7179                	addi	sp,sp,-48
    80002cac:	f406                	sd	ra,40(sp)
    80002cae:	f022                	sd	s0,32(sp)
    80002cb0:	ec26                	sd	s1,24(sp)
    80002cb2:	1800                	addi	s0,sp,48
  uint64 addr;
  int n;

  argint(0, &n);
    80002cb4:	fdc40593          	addi	a1,s0,-36
    80002cb8:	4501                	li	a0,0
    80002cba:	00000097          	auipc	ra,0x0
    80002cbe:	e84080e7          	jalr	-380(ra) # 80002b3e <argint>
  addr = myproc()->sz;
    80002cc2:	fffff097          	auipc	ra,0xfffff
    80002cc6:	d68080e7          	jalr	-664(ra) # 80001a2a <myproc>
    80002cca:	6524                	ld	s1,72(a0)
  if(growproc(n) < 0)
    80002ccc:	fdc42503          	lw	a0,-36(s0)
    80002cd0:	fffff097          	auipc	ra,0xfffff
    80002cd4:	0b4080e7          	jalr	180(ra) # 80001d84 <growproc>
    80002cd8:	00054863          	bltz	a0,80002ce8 <sys_sbrk+0x3e>
    return -1;
  return addr;
}
    80002cdc:	8526                	mv	a0,s1
    80002cde:	70a2                	ld	ra,40(sp)
    80002ce0:	7402                	ld	s0,32(sp)
    80002ce2:	64e2                	ld	s1,24(sp)
    80002ce4:	6145                	addi	sp,sp,48
    80002ce6:	8082                	ret
    return -1;
    80002ce8:	54fd                	li	s1,-1
    80002cea:	bfcd                	j	80002cdc <sys_sbrk+0x32>

0000000080002cec <sys_sleep>:

uint64
sys_sleep(void)
{
    80002cec:	7139                	addi	sp,sp,-64
    80002cee:	fc06                	sd	ra,56(sp)
    80002cf0:	f822                	sd	s0,48(sp)
    80002cf2:	f426                	sd	s1,40(sp)
    80002cf4:	f04a                	sd	s2,32(sp)
    80002cf6:	ec4e                	sd	s3,24(sp)
    80002cf8:	0080                	addi	s0,sp,64
  int n;
  uint ticks0;

  argint(0, &n);
    80002cfa:	fcc40593          	addi	a1,s0,-52
    80002cfe:	4501                	li	a0,0
    80002d00:	00000097          	auipc	ra,0x0
    80002d04:	e3e080e7          	jalr	-450(ra) # 80002b3e <argint>
  acquire(&tickslock);
    80002d08:	00014517          	auipc	a0,0x14
    80002d0c:	c9850513          	addi	a0,a0,-872 # 800169a0 <tickslock>
    80002d10:	ffffe097          	auipc	ra,0xffffe
    80002d14:	f2a080e7          	jalr	-214(ra) # 80000c3a <acquire>
  ticks0 = ticks;
    80002d18:	00006917          	auipc	s2,0x6
    80002d1c:	be892903          	lw	s2,-1048(s2) # 80008900 <ticks>
  while(ticks - ticks0 < n){
    80002d20:	fcc42783          	lw	a5,-52(s0)
    80002d24:	cf9d                	beqz	a5,80002d62 <sys_sleep+0x76>
    if(killed(myproc())){
      release(&tickslock);
      return -1;
    }
    sleep(&ticks, &tickslock);
    80002d26:	00014997          	auipc	s3,0x14
    80002d2a:	c7a98993          	addi	s3,s3,-902 # 800169a0 <tickslock>
    80002d2e:	00006497          	auipc	s1,0x6
    80002d32:	bd248493          	addi	s1,s1,-1070 # 80008900 <ticks>
    if(killed(myproc())){
    80002d36:	fffff097          	auipc	ra,0xfffff
    80002d3a:	cf4080e7          	jalr	-780(ra) # 80001a2a <myproc>
    80002d3e:	fffff097          	auipc	ra,0xfffff
    80002d42:	63c080e7          	jalr	1596(ra) # 8000237a <killed>
    80002d46:	ed15                	bnez	a0,80002d82 <sys_sleep+0x96>
    sleep(&ticks, &tickslock);
    80002d48:	85ce                	mv	a1,s3
    80002d4a:	8526                	mv	a0,s1
    80002d4c:	fffff097          	auipc	ra,0xfffff
    80002d50:	386080e7          	jalr	902(ra) # 800020d2 <sleep>
  while(ticks - ticks0 < n){
    80002d54:	409c                	lw	a5,0(s1)
    80002d56:	412787bb          	subw	a5,a5,s2
    80002d5a:	fcc42703          	lw	a4,-52(s0)
    80002d5e:	fce7ece3          	bltu	a5,a4,80002d36 <sys_sleep+0x4a>
  }
  release(&tickslock);
    80002d62:	00014517          	auipc	a0,0x14
    80002d66:	c3e50513          	addi	a0,a0,-962 # 800169a0 <tickslock>
    80002d6a:	ffffe097          	auipc	ra,0xffffe
    80002d6e:	f84080e7          	jalr	-124(ra) # 80000cee <release>
  return 0;
    80002d72:	4501                	li	a0,0
}
    80002d74:	70e2                	ld	ra,56(sp)
    80002d76:	7442                	ld	s0,48(sp)
    80002d78:	74a2                	ld	s1,40(sp)
    80002d7a:	7902                	ld	s2,32(sp)
    80002d7c:	69e2                	ld	s3,24(sp)
    80002d7e:	6121                	addi	sp,sp,64
    80002d80:	8082                	ret
      release(&tickslock);
    80002d82:	00014517          	auipc	a0,0x14
    80002d86:	c1e50513          	addi	a0,a0,-994 # 800169a0 <tickslock>
    80002d8a:	ffffe097          	auipc	ra,0xffffe
    80002d8e:	f64080e7          	jalr	-156(ra) # 80000cee <release>
      return -1;
    80002d92:	557d                	li	a0,-1
    80002d94:	b7c5                	j	80002d74 <sys_sleep+0x88>

0000000080002d96 <sys_kill>:

uint64
sys_kill(void)
{
    80002d96:	1101                	addi	sp,sp,-32
    80002d98:	ec06                	sd	ra,24(sp)
    80002d9a:	e822                	sd	s0,16(sp)
    80002d9c:	1000                	addi	s0,sp,32
  int pid;

  argint(0, &pid);
    80002d9e:	fec40593          	addi	a1,s0,-20
    80002da2:	4501                	li	a0,0
    80002da4:	00000097          	auipc	ra,0x0
    80002da8:	d9a080e7          	jalr	-614(ra) # 80002b3e <argint>
  return kill(pid);
    80002dac:	fec42503          	lw	a0,-20(s0)
    80002db0:	fffff097          	auipc	ra,0xfffff
    80002db4:	52c080e7          	jalr	1324(ra) # 800022dc <kill>
}
    80002db8:	60e2                	ld	ra,24(sp)
    80002dba:	6442                	ld	s0,16(sp)
    80002dbc:	6105                	addi	sp,sp,32
    80002dbe:	8082                	ret

0000000080002dc0 <sys_uptime>:

// return how many clock tick interrupts have occurred
// since start.
uint64
sys_uptime(void)
{
    80002dc0:	1101                	addi	sp,sp,-32
    80002dc2:	ec06                	sd	ra,24(sp)
    80002dc4:	e822                	sd	s0,16(sp)
    80002dc6:	e426                	sd	s1,8(sp)
    80002dc8:	1000                	addi	s0,sp,32
  uint xticks;

  acquire(&tickslock);
    80002dca:	00014517          	auipc	a0,0x14
    80002dce:	bd650513          	addi	a0,a0,-1066 # 800169a0 <tickslock>
    80002dd2:	ffffe097          	auipc	ra,0xffffe
    80002dd6:	e68080e7          	jalr	-408(ra) # 80000c3a <acquire>
  xticks = ticks;
    80002dda:	00006497          	auipc	s1,0x6
    80002dde:	b264a483          	lw	s1,-1242(s1) # 80008900 <ticks>
  release(&tickslock);
    80002de2:	00014517          	auipc	a0,0x14
    80002de6:	bbe50513          	addi	a0,a0,-1090 # 800169a0 <tickslock>
    80002dea:	ffffe097          	auipc	ra,0xffffe
    80002dee:	f04080e7          	jalr	-252(ra) # 80000cee <release>
  return xticks;
}
    80002df2:	02049513          	slli	a0,s1,0x20
    80002df6:	9101                	srli	a0,a0,0x20
    80002df8:	60e2                	ld	ra,24(sp)
    80002dfa:	6442                	ld	s0,16(sp)
    80002dfc:	64a2                	ld	s1,8(sp)
    80002dfe:	6105                	addi	sp,sp,32
    80002e00:	8082                	ret

0000000080002e02 <sys_kfreemem>:

uint64
sys_kfreemem(void)

{
    80002e02:	1141                	addi	sp,sp,-16
    80002e04:	e406                	sd	ra,8(sp)
    80002e06:	e022                	sd	s0,0(sp)
    80002e08:	0800                	addi	s0,sp,16
    return kfreemem();
    80002e0a:	ffffe097          	auipc	ra,0xffffe
    80002e0e:	d84080e7          	jalr	-636(ra) # 80000b8e <kfreemem>
}
    80002e12:	60a2                	ld	ra,8(sp)
    80002e14:	6402                	ld	s0,0(sp)
    80002e16:	0141                	addi	sp,sp,16
    80002e18:	8082                	ret

0000000080002e1a <binit>:
  struct buf head;
} bcache;

void
binit(void)
{
    80002e1a:	7179                	addi	sp,sp,-48
    80002e1c:	f406                	sd	ra,40(sp)
    80002e1e:	f022                	sd	s0,32(sp)
    80002e20:	ec26                	sd	s1,24(sp)
    80002e22:	e84a                	sd	s2,16(sp)
    80002e24:	e44e                	sd	s3,8(sp)
    80002e26:	e052                	sd	s4,0(sp)
    80002e28:	1800                	addi	s0,sp,48
  struct buf *b;

  initlock(&bcache.lock, "bcache");
    80002e2a:	00005597          	auipc	a1,0x5
    80002e2e:	71658593          	addi	a1,a1,1814 # 80008540 <syscalls+0xb8>
    80002e32:	00014517          	auipc	a0,0x14
    80002e36:	b8650513          	addi	a0,a0,-1146 # 800169b8 <bcache>
    80002e3a:	ffffe097          	auipc	ra,0xffffe
    80002e3e:	d70080e7          	jalr	-656(ra) # 80000baa <initlock>

  // Create linked list of buffers
  bcache.head.prev = &bcache.head;
    80002e42:	0001c797          	auipc	a5,0x1c
    80002e46:	b7678793          	addi	a5,a5,-1162 # 8001e9b8 <bcache+0x8000>
    80002e4a:	0001c717          	auipc	a4,0x1c
    80002e4e:	dd670713          	addi	a4,a4,-554 # 8001ec20 <bcache+0x8268>
    80002e52:	2ae7b823          	sd	a4,688(a5)
  bcache.head.next = &bcache.head;
    80002e56:	2ae7bc23          	sd	a4,696(a5)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    80002e5a:	00014497          	auipc	s1,0x14
    80002e5e:	b7648493          	addi	s1,s1,-1162 # 800169d0 <bcache+0x18>
    b->next = bcache.head.next;
    80002e62:	893e                	mv	s2,a5
    b->prev = &bcache.head;
    80002e64:	89ba                	mv	s3,a4
    initsleeplock(&b->lock, "buffer");
    80002e66:	00005a17          	auipc	s4,0x5
    80002e6a:	6e2a0a13          	addi	s4,s4,1762 # 80008548 <syscalls+0xc0>
    b->next = bcache.head.next;
    80002e6e:	2b893783          	ld	a5,696(s2)
    80002e72:	e8bc                	sd	a5,80(s1)
    b->prev = &bcache.head;
    80002e74:	0534b423          	sd	s3,72(s1)
    initsleeplock(&b->lock, "buffer");
    80002e78:	85d2                	mv	a1,s4
    80002e7a:	01048513          	addi	a0,s1,16
    80002e7e:	00001097          	auipc	ra,0x1
    80002e82:	4c4080e7          	jalr	1220(ra) # 80004342 <initsleeplock>
    bcache.head.next->prev = b;
    80002e86:	2b893783          	ld	a5,696(s2)
    80002e8a:	e7a4                	sd	s1,72(a5)
    bcache.head.next = b;
    80002e8c:	2a993c23          	sd	s1,696(s2)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    80002e90:	45848493          	addi	s1,s1,1112
    80002e94:	fd349de3          	bne	s1,s3,80002e6e <binit+0x54>
  }
}
    80002e98:	70a2                	ld	ra,40(sp)
    80002e9a:	7402                	ld	s0,32(sp)
    80002e9c:	64e2                	ld	s1,24(sp)
    80002e9e:	6942                	ld	s2,16(sp)
    80002ea0:	69a2                	ld	s3,8(sp)
    80002ea2:	6a02                	ld	s4,0(sp)
    80002ea4:	6145                	addi	sp,sp,48
    80002ea6:	8082                	ret

0000000080002ea8 <bread>:
}

// Return a locked buf with the contents of the indicated block.
struct buf*
bread(uint dev, uint blockno)
{
    80002ea8:	7179                	addi	sp,sp,-48
    80002eaa:	f406                	sd	ra,40(sp)
    80002eac:	f022                	sd	s0,32(sp)
    80002eae:	ec26                	sd	s1,24(sp)
    80002eb0:	e84a                	sd	s2,16(sp)
    80002eb2:	e44e                	sd	s3,8(sp)
    80002eb4:	1800                	addi	s0,sp,48
    80002eb6:	892a                	mv	s2,a0
    80002eb8:	89ae                	mv	s3,a1
  acquire(&bcache.lock);
    80002eba:	00014517          	auipc	a0,0x14
    80002ebe:	afe50513          	addi	a0,a0,-1282 # 800169b8 <bcache>
    80002ec2:	ffffe097          	auipc	ra,0xffffe
    80002ec6:	d78080e7          	jalr	-648(ra) # 80000c3a <acquire>
  for(b = bcache.head.next; b != &bcache.head; b = b->next){
    80002eca:	0001c497          	auipc	s1,0x1c
    80002ece:	da64b483          	ld	s1,-602(s1) # 8001ec70 <bcache+0x82b8>
    80002ed2:	0001c797          	auipc	a5,0x1c
    80002ed6:	d4e78793          	addi	a5,a5,-690 # 8001ec20 <bcache+0x8268>
    80002eda:	02f48f63          	beq	s1,a5,80002f18 <bread+0x70>
    80002ede:	873e                	mv	a4,a5
    80002ee0:	a021                	j	80002ee8 <bread+0x40>
    80002ee2:	68a4                	ld	s1,80(s1)
    80002ee4:	02e48a63          	beq	s1,a4,80002f18 <bread+0x70>
    if(b->dev == dev && b->blockno == blockno){
    80002ee8:	449c                	lw	a5,8(s1)
    80002eea:	ff279ce3          	bne	a5,s2,80002ee2 <bread+0x3a>
    80002eee:	44dc                	lw	a5,12(s1)
    80002ef0:	ff3799e3          	bne	a5,s3,80002ee2 <bread+0x3a>
      b->refcnt++;
    80002ef4:	40bc                	lw	a5,64(s1)
    80002ef6:	2785                	addiw	a5,a5,1
    80002ef8:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    80002efa:	00014517          	auipc	a0,0x14
    80002efe:	abe50513          	addi	a0,a0,-1346 # 800169b8 <bcache>
    80002f02:	ffffe097          	auipc	ra,0xffffe
    80002f06:	dec080e7          	jalr	-532(ra) # 80000cee <release>
      acquiresleep(&b->lock);
    80002f0a:	01048513          	addi	a0,s1,16
    80002f0e:	00001097          	auipc	ra,0x1
    80002f12:	46e080e7          	jalr	1134(ra) # 8000437c <acquiresleep>
      return b;
    80002f16:	a8b9                	j	80002f74 <bread+0xcc>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    80002f18:	0001c497          	auipc	s1,0x1c
    80002f1c:	d504b483          	ld	s1,-688(s1) # 8001ec68 <bcache+0x82b0>
    80002f20:	0001c797          	auipc	a5,0x1c
    80002f24:	d0078793          	addi	a5,a5,-768 # 8001ec20 <bcache+0x8268>
    80002f28:	00f48863          	beq	s1,a5,80002f38 <bread+0x90>
    80002f2c:	873e                	mv	a4,a5
    if(b->refcnt == 0) {
    80002f2e:	40bc                	lw	a5,64(s1)
    80002f30:	cf81                	beqz	a5,80002f48 <bread+0xa0>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    80002f32:	64a4                	ld	s1,72(s1)
    80002f34:	fee49de3          	bne	s1,a4,80002f2e <bread+0x86>
  panic("bget: no buffers");
    80002f38:	00005517          	auipc	a0,0x5
    80002f3c:	61850513          	addi	a0,a0,1560 # 80008550 <syscalls+0xc8>
    80002f40:	ffffd097          	auipc	ra,0xffffd
    80002f44:	5fe080e7          	jalr	1534(ra) # 8000053e <panic>
      b->dev = dev;
    80002f48:	0124a423          	sw	s2,8(s1)
      b->blockno = blockno;
    80002f4c:	0134a623          	sw	s3,12(s1)
      b->valid = 0;
    80002f50:	0004a023          	sw	zero,0(s1)
      b->refcnt = 1;
    80002f54:	4785                	li	a5,1
    80002f56:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    80002f58:	00014517          	auipc	a0,0x14
    80002f5c:	a6050513          	addi	a0,a0,-1440 # 800169b8 <bcache>
    80002f60:	ffffe097          	auipc	ra,0xffffe
    80002f64:	d8e080e7          	jalr	-626(ra) # 80000cee <release>
      acquiresleep(&b->lock);
    80002f68:	01048513          	addi	a0,s1,16
    80002f6c:	00001097          	auipc	ra,0x1
    80002f70:	410080e7          	jalr	1040(ra) # 8000437c <acquiresleep>
  struct buf *b;

  b = bget(dev, blockno);
  if(!b->valid) {
    80002f74:	409c                	lw	a5,0(s1)
    80002f76:	cb89                	beqz	a5,80002f88 <bread+0xe0>
    virtio_disk_rw(b, 0);
    b->valid = 1;
  }
  return b;
}
    80002f78:	8526                	mv	a0,s1
    80002f7a:	70a2                	ld	ra,40(sp)
    80002f7c:	7402                	ld	s0,32(sp)
    80002f7e:	64e2                	ld	s1,24(sp)
    80002f80:	6942                	ld	s2,16(sp)
    80002f82:	69a2                	ld	s3,8(sp)
    80002f84:	6145                	addi	sp,sp,48
    80002f86:	8082                	ret
    virtio_disk_rw(b, 0);
    80002f88:	4581                	li	a1,0
    80002f8a:	8526                	mv	a0,s1
    80002f8c:	00003097          	auipc	ra,0x3
    80002f90:	fd8080e7          	jalr	-40(ra) # 80005f64 <virtio_disk_rw>
    b->valid = 1;
    80002f94:	4785                	li	a5,1
    80002f96:	c09c                	sw	a5,0(s1)
  return b;
    80002f98:	b7c5                	j	80002f78 <bread+0xd0>

0000000080002f9a <bwrite>:

// Write b's contents to disk.  Must be locked.
void
bwrite(struct buf *b)
{
    80002f9a:	1101                	addi	sp,sp,-32
    80002f9c:	ec06                	sd	ra,24(sp)
    80002f9e:	e822                	sd	s0,16(sp)
    80002fa0:	e426                	sd	s1,8(sp)
    80002fa2:	1000                	addi	s0,sp,32
    80002fa4:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    80002fa6:	0541                	addi	a0,a0,16
    80002fa8:	00001097          	auipc	ra,0x1
    80002fac:	46e080e7          	jalr	1134(ra) # 80004416 <holdingsleep>
    80002fb0:	cd01                	beqz	a0,80002fc8 <bwrite+0x2e>
    panic("bwrite");
  virtio_disk_rw(b, 1);
    80002fb2:	4585                	li	a1,1
    80002fb4:	8526                	mv	a0,s1
    80002fb6:	00003097          	auipc	ra,0x3
    80002fba:	fae080e7          	jalr	-82(ra) # 80005f64 <virtio_disk_rw>
}
    80002fbe:	60e2                	ld	ra,24(sp)
    80002fc0:	6442                	ld	s0,16(sp)
    80002fc2:	64a2                	ld	s1,8(sp)
    80002fc4:	6105                	addi	sp,sp,32
    80002fc6:	8082                	ret
    panic("bwrite");
    80002fc8:	00005517          	auipc	a0,0x5
    80002fcc:	5a050513          	addi	a0,a0,1440 # 80008568 <syscalls+0xe0>
    80002fd0:	ffffd097          	auipc	ra,0xffffd
    80002fd4:	56e080e7          	jalr	1390(ra) # 8000053e <panic>

0000000080002fd8 <brelse>:

// Release a locked buffer.
// Move to the head of the most-recently-used list.
void
brelse(struct buf *b)
{
    80002fd8:	1101                	addi	sp,sp,-32
    80002fda:	ec06                	sd	ra,24(sp)
    80002fdc:	e822                	sd	s0,16(sp)
    80002fde:	e426                	sd	s1,8(sp)
    80002fe0:	e04a                	sd	s2,0(sp)
    80002fe2:	1000                	addi	s0,sp,32
    80002fe4:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    80002fe6:	01050913          	addi	s2,a0,16
    80002fea:	854a                	mv	a0,s2
    80002fec:	00001097          	auipc	ra,0x1
    80002ff0:	42a080e7          	jalr	1066(ra) # 80004416 <holdingsleep>
    80002ff4:	c92d                	beqz	a0,80003066 <brelse+0x8e>
    panic("brelse");

  releasesleep(&b->lock);
    80002ff6:	854a                	mv	a0,s2
    80002ff8:	00001097          	auipc	ra,0x1
    80002ffc:	3da080e7          	jalr	986(ra) # 800043d2 <releasesleep>

  acquire(&bcache.lock);
    80003000:	00014517          	auipc	a0,0x14
    80003004:	9b850513          	addi	a0,a0,-1608 # 800169b8 <bcache>
    80003008:	ffffe097          	auipc	ra,0xffffe
    8000300c:	c32080e7          	jalr	-974(ra) # 80000c3a <acquire>
  b->refcnt--;
    80003010:	40bc                	lw	a5,64(s1)
    80003012:	37fd                	addiw	a5,a5,-1
    80003014:	0007871b          	sext.w	a4,a5
    80003018:	c0bc                	sw	a5,64(s1)
  if (b->refcnt == 0) {
    8000301a:	eb05                	bnez	a4,8000304a <brelse+0x72>
    // no one is waiting for it.
    b->next->prev = b->prev;
    8000301c:	68bc                	ld	a5,80(s1)
    8000301e:	64b8                	ld	a4,72(s1)
    80003020:	e7b8                	sd	a4,72(a5)
    b->prev->next = b->next;
    80003022:	64bc                	ld	a5,72(s1)
    80003024:	68b8                	ld	a4,80(s1)
    80003026:	ebb8                	sd	a4,80(a5)
    b->next = bcache.head.next;
    80003028:	0001c797          	auipc	a5,0x1c
    8000302c:	99078793          	addi	a5,a5,-1648 # 8001e9b8 <bcache+0x8000>
    80003030:	2b87b703          	ld	a4,696(a5)
    80003034:	e8b8                	sd	a4,80(s1)
    b->prev = &bcache.head;
    80003036:	0001c717          	auipc	a4,0x1c
    8000303a:	bea70713          	addi	a4,a4,-1046 # 8001ec20 <bcache+0x8268>
    8000303e:	e4b8                	sd	a4,72(s1)
    bcache.head.next->prev = b;
    80003040:	2b87b703          	ld	a4,696(a5)
    80003044:	e724                	sd	s1,72(a4)
    bcache.head.next = b;
    80003046:	2a97bc23          	sd	s1,696(a5)
  }
  
  release(&bcache.lock);
    8000304a:	00014517          	auipc	a0,0x14
    8000304e:	96e50513          	addi	a0,a0,-1682 # 800169b8 <bcache>
    80003052:	ffffe097          	auipc	ra,0xffffe
    80003056:	c9c080e7          	jalr	-868(ra) # 80000cee <release>
}
    8000305a:	60e2                	ld	ra,24(sp)
    8000305c:	6442                	ld	s0,16(sp)
    8000305e:	64a2                	ld	s1,8(sp)
    80003060:	6902                	ld	s2,0(sp)
    80003062:	6105                	addi	sp,sp,32
    80003064:	8082                	ret
    panic("brelse");
    80003066:	00005517          	auipc	a0,0x5
    8000306a:	50a50513          	addi	a0,a0,1290 # 80008570 <syscalls+0xe8>
    8000306e:	ffffd097          	auipc	ra,0xffffd
    80003072:	4d0080e7          	jalr	1232(ra) # 8000053e <panic>

0000000080003076 <bpin>:

void
bpin(struct buf *b) {
    80003076:	1101                	addi	sp,sp,-32
    80003078:	ec06                	sd	ra,24(sp)
    8000307a:	e822                	sd	s0,16(sp)
    8000307c:	e426                	sd	s1,8(sp)
    8000307e:	1000                	addi	s0,sp,32
    80003080:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    80003082:	00014517          	auipc	a0,0x14
    80003086:	93650513          	addi	a0,a0,-1738 # 800169b8 <bcache>
    8000308a:	ffffe097          	auipc	ra,0xffffe
    8000308e:	bb0080e7          	jalr	-1104(ra) # 80000c3a <acquire>
  b->refcnt++;
    80003092:	40bc                	lw	a5,64(s1)
    80003094:	2785                	addiw	a5,a5,1
    80003096:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    80003098:	00014517          	auipc	a0,0x14
    8000309c:	92050513          	addi	a0,a0,-1760 # 800169b8 <bcache>
    800030a0:	ffffe097          	auipc	ra,0xffffe
    800030a4:	c4e080e7          	jalr	-946(ra) # 80000cee <release>
}
    800030a8:	60e2                	ld	ra,24(sp)
    800030aa:	6442                	ld	s0,16(sp)
    800030ac:	64a2                	ld	s1,8(sp)
    800030ae:	6105                	addi	sp,sp,32
    800030b0:	8082                	ret

00000000800030b2 <bunpin>:

void
bunpin(struct buf *b) {
    800030b2:	1101                	addi	sp,sp,-32
    800030b4:	ec06                	sd	ra,24(sp)
    800030b6:	e822                	sd	s0,16(sp)
    800030b8:	e426                	sd	s1,8(sp)
    800030ba:	1000                	addi	s0,sp,32
    800030bc:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    800030be:	00014517          	auipc	a0,0x14
    800030c2:	8fa50513          	addi	a0,a0,-1798 # 800169b8 <bcache>
    800030c6:	ffffe097          	auipc	ra,0xffffe
    800030ca:	b74080e7          	jalr	-1164(ra) # 80000c3a <acquire>
  b->refcnt--;
    800030ce:	40bc                	lw	a5,64(s1)
    800030d0:	37fd                	addiw	a5,a5,-1
    800030d2:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    800030d4:	00014517          	auipc	a0,0x14
    800030d8:	8e450513          	addi	a0,a0,-1820 # 800169b8 <bcache>
    800030dc:	ffffe097          	auipc	ra,0xffffe
    800030e0:	c12080e7          	jalr	-1006(ra) # 80000cee <release>
}
    800030e4:	60e2                	ld	ra,24(sp)
    800030e6:	6442                	ld	s0,16(sp)
    800030e8:	64a2                	ld	s1,8(sp)
    800030ea:	6105                	addi	sp,sp,32
    800030ec:	8082                	ret

00000000800030ee <bfree>:
}

// Free a disk block.
static void
bfree(int dev, uint b)
{
    800030ee:	1101                	addi	sp,sp,-32
    800030f0:	ec06                	sd	ra,24(sp)
    800030f2:	e822                	sd	s0,16(sp)
    800030f4:	e426                	sd	s1,8(sp)
    800030f6:	e04a                	sd	s2,0(sp)
    800030f8:	1000                	addi	s0,sp,32
    800030fa:	84ae                	mv	s1,a1
  struct buf *bp;
  int bi, m;

  bp = bread(dev, BBLOCK(b, sb));
    800030fc:	00d5d59b          	srliw	a1,a1,0xd
    80003100:	0001c797          	auipc	a5,0x1c
    80003104:	f947a783          	lw	a5,-108(a5) # 8001f094 <sb+0x1c>
    80003108:	9dbd                	addw	a1,a1,a5
    8000310a:	00000097          	auipc	ra,0x0
    8000310e:	d9e080e7          	jalr	-610(ra) # 80002ea8 <bread>
  bi = b % BPB;
  m = 1 << (bi % 8);
    80003112:	0074f713          	andi	a4,s1,7
    80003116:	4785                	li	a5,1
    80003118:	00e797bb          	sllw	a5,a5,a4
  if((bp->data[bi/8] & m) == 0)
    8000311c:	14ce                	slli	s1,s1,0x33
    8000311e:	90d9                	srli	s1,s1,0x36
    80003120:	00950733          	add	a4,a0,s1
    80003124:	05874703          	lbu	a4,88(a4)
    80003128:	00e7f6b3          	and	a3,a5,a4
    8000312c:	c69d                	beqz	a3,8000315a <bfree+0x6c>
    8000312e:	892a                	mv	s2,a0
    panic("freeing free block");
  bp->data[bi/8] &= ~m;
    80003130:	94aa                	add	s1,s1,a0
    80003132:	fff7c793          	not	a5,a5
    80003136:	8ff9                	and	a5,a5,a4
    80003138:	04f48c23          	sb	a5,88(s1)
  log_write(bp);
    8000313c:	00001097          	auipc	ra,0x1
    80003140:	120080e7          	jalr	288(ra) # 8000425c <log_write>
  brelse(bp);
    80003144:	854a                	mv	a0,s2
    80003146:	00000097          	auipc	ra,0x0
    8000314a:	e92080e7          	jalr	-366(ra) # 80002fd8 <brelse>
}
    8000314e:	60e2                	ld	ra,24(sp)
    80003150:	6442                	ld	s0,16(sp)
    80003152:	64a2                	ld	s1,8(sp)
    80003154:	6902                	ld	s2,0(sp)
    80003156:	6105                	addi	sp,sp,32
    80003158:	8082                	ret
    panic("freeing free block");
    8000315a:	00005517          	auipc	a0,0x5
    8000315e:	41e50513          	addi	a0,a0,1054 # 80008578 <syscalls+0xf0>
    80003162:	ffffd097          	auipc	ra,0xffffd
    80003166:	3dc080e7          	jalr	988(ra) # 8000053e <panic>

000000008000316a <balloc>:
{
    8000316a:	711d                	addi	sp,sp,-96
    8000316c:	ec86                	sd	ra,88(sp)
    8000316e:	e8a2                	sd	s0,80(sp)
    80003170:	e4a6                	sd	s1,72(sp)
    80003172:	e0ca                	sd	s2,64(sp)
    80003174:	fc4e                	sd	s3,56(sp)
    80003176:	f852                	sd	s4,48(sp)
    80003178:	f456                	sd	s5,40(sp)
    8000317a:	f05a                	sd	s6,32(sp)
    8000317c:	ec5e                	sd	s7,24(sp)
    8000317e:	e862                	sd	s8,16(sp)
    80003180:	e466                	sd	s9,8(sp)
    80003182:	1080                	addi	s0,sp,96
  for(b = 0; b < sb.size; b += BPB){
    80003184:	0001c797          	auipc	a5,0x1c
    80003188:	ef87a783          	lw	a5,-264(a5) # 8001f07c <sb+0x4>
    8000318c:	10078163          	beqz	a5,8000328e <balloc+0x124>
    80003190:	8baa                	mv	s7,a0
    80003192:	4a81                	li	s5,0
    bp = bread(dev, BBLOCK(b, sb));
    80003194:	0001cb17          	auipc	s6,0x1c
    80003198:	ee4b0b13          	addi	s6,s6,-284 # 8001f078 <sb>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    8000319c:	4c01                	li	s8,0
      m = 1 << (bi % 8);
    8000319e:	4985                	li	s3,1
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    800031a0:	6a09                	lui	s4,0x2
  for(b = 0; b < sb.size; b += BPB){
    800031a2:	6c89                	lui	s9,0x2
    800031a4:	a061                	j	8000322c <balloc+0xc2>
        bp->data[bi/8] |= m;  // Mark block in use.
    800031a6:	974a                	add	a4,a4,s2
    800031a8:	8fd5                	or	a5,a5,a3
    800031aa:	04f70c23          	sb	a5,88(a4)
        log_write(bp);
    800031ae:	854a                	mv	a0,s2
    800031b0:	00001097          	auipc	ra,0x1
    800031b4:	0ac080e7          	jalr	172(ra) # 8000425c <log_write>
        brelse(bp);
    800031b8:	854a                	mv	a0,s2
    800031ba:	00000097          	auipc	ra,0x0
    800031be:	e1e080e7          	jalr	-482(ra) # 80002fd8 <brelse>
  bp = bread(dev, bno);
    800031c2:	85a6                	mv	a1,s1
    800031c4:	855e                	mv	a0,s7
    800031c6:	00000097          	auipc	ra,0x0
    800031ca:	ce2080e7          	jalr	-798(ra) # 80002ea8 <bread>
    800031ce:	892a                	mv	s2,a0
  memset(bp->data, 0, BSIZE);
    800031d0:	40000613          	li	a2,1024
    800031d4:	4581                	li	a1,0
    800031d6:	05850513          	addi	a0,a0,88
    800031da:	ffffe097          	auipc	ra,0xffffe
    800031de:	b5c080e7          	jalr	-1188(ra) # 80000d36 <memset>
  log_write(bp);
    800031e2:	854a                	mv	a0,s2
    800031e4:	00001097          	auipc	ra,0x1
    800031e8:	078080e7          	jalr	120(ra) # 8000425c <log_write>
  brelse(bp);
    800031ec:	854a                	mv	a0,s2
    800031ee:	00000097          	auipc	ra,0x0
    800031f2:	dea080e7          	jalr	-534(ra) # 80002fd8 <brelse>
}
    800031f6:	8526                	mv	a0,s1
    800031f8:	60e6                	ld	ra,88(sp)
    800031fa:	6446                	ld	s0,80(sp)
    800031fc:	64a6                	ld	s1,72(sp)
    800031fe:	6906                	ld	s2,64(sp)
    80003200:	79e2                	ld	s3,56(sp)
    80003202:	7a42                	ld	s4,48(sp)
    80003204:	7aa2                	ld	s5,40(sp)
    80003206:	7b02                	ld	s6,32(sp)
    80003208:	6be2                	ld	s7,24(sp)
    8000320a:	6c42                	ld	s8,16(sp)
    8000320c:	6ca2                	ld	s9,8(sp)
    8000320e:	6125                	addi	sp,sp,96
    80003210:	8082                	ret
    brelse(bp);
    80003212:	854a                	mv	a0,s2
    80003214:	00000097          	auipc	ra,0x0
    80003218:	dc4080e7          	jalr	-572(ra) # 80002fd8 <brelse>
  for(b = 0; b < sb.size; b += BPB){
    8000321c:	015c87bb          	addw	a5,s9,s5
    80003220:	00078a9b          	sext.w	s5,a5
    80003224:	004b2703          	lw	a4,4(s6)
    80003228:	06eaf363          	bgeu	s5,a4,8000328e <balloc+0x124>
    bp = bread(dev, BBLOCK(b, sb));
    8000322c:	41fad79b          	sraiw	a5,s5,0x1f
    80003230:	0137d79b          	srliw	a5,a5,0x13
    80003234:	015787bb          	addw	a5,a5,s5
    80003238:	40d7d79b          	sraiw	a5,a5,0xd
    8000323c:	01cb2583          	lw	a1,28(s6)
    80003240:	9dbd                	addw	a1,a1,a5
    80003242:	855e                	mv	a0,s7
    80003244:	00000097          	auipc	ra,0x0
    80003248:	c64080e7          	jalr	-924(ra) # 80002ea8 <bread>
    8000324c:	892a                	mv	s2,a0
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    8000324e:	004b2503          	lw	a0,4(s6)
    80003252:	000a849b          	sext.w	s1,s5
    80003256:	8662                	mv	a2,s8
    80003258:	faa4fde3          	bgeu	s1,a0,80003212 <balloc+0xa8>
      m = 1 << (bi % 8);
    8000325c:	41f6579b          	sraiw	a5,a2,0x1f
    80003260:	01d7d69b          	srliw	a3,a5,0x1d
    80003264:	00c6873b          	addw	a4,a3,a2
    80003268:	00777793          	andi	a5,a4,7
    8000326c:	9f95                	subw	a5,a5,a3
    8000326e:	00f997bb          	sllw	a5,s3,a5
      if((bp->data[bi/8] & m) == 0){  // Is block free?
    80003272:	4037571b          	sraiw	a4,a4,0x3
    80003276:	00e906b3          	add	a3,s2,a4
    8000327a:	0586c683          	lbu	a3,88(a3)
    8000327e:	00d7f5b3          	and	a1,a5,a3
    80003282:	d195                	beqz	a1,800031a6 <balloc+0x3c>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80003284:	2605                	addiw	a2,a2,1
    80003286:	2485                	addiw	s1,s1,1
    80003288:	fd4618e3          	bne	a2,s4,80003258 <balloc+0xee>
    8000328c:	b759                	j	80003212 <balloc+0xa8>
  printf("balloc: out of blocks\n");
    8000328e:	00005517          	auipc	a0,0x5
    80003292:	30250513          	addi	a0,a0,770 # 80008590 <syscalls+0x108>
    80003296:	ffffd097          	auipc	ra,0xffffd
    8000329a:	2f2080e7          	jalr	754(ra) # 80000588 <printf>
  return 0;
    8000329e:	4481                	li	s1,0
    800032a0:	bf99                	j	800031f6 <balloc+0x8c>

00000000800032a2 <bmap>:
// Return the disk block address of the nth block in inode ip.
// If there is no such block, bmap allocates one.
// returns 0 if out of disk space.
static uint
bmap(struct inode *ip, uint bn)
{
    800032a2:	7179                	addi	sp,sp,-48
    800032a4:	f406                	sd	ra,40(sp)
    800032a6:	f022                	sd	s0,32(sp)
    800032a8:	ec26                	sd	s1,24(sp)
    800032aa:	e84a                	sd	s2,16(sp)
    800032ac:	e44e                	sd	s3,8(sp)
    800032ae:	e052                	sd	s4,0(sp)
    800032b0:	1800                	addi	s0,sp,48
    800032b2:	89aa                	mv	s3,a0
  uint addr, *a;
  struct buf *bp;

  if(bn < NDIRECT){
    800032b4:	47ad                	li	a5,11
    800032b6:	02b7e763          	bltu	a5,a1,800032e4 <bmap+0x42>
    if((addr = ip->addrs[bn]) == 0){
    800032ba:	02059493          	slli	s1,a1,0x20
    800032be:	9081                	srli	s1,s1,0x20
    800032c0:	048a                	slli	s1,s1,0x2
    800032c2:	94aa                	add	s1,s1,a0
    800032c4:	0504a903          	lw	s2,80(s1)
    800032c8:	06091e63          	bnez	s2,80003344 <bmap+0xa2>
      addr = balloc(ip->dev);
    800032cc:	4108                	lw	a0,0(a0)
    800032ce:	00000097          	auipc	ra,0x0
    800032d2:	e9c080e7          	jalr	-356(ra) # 8000316a <balloc>
    800032d6:	0005091b          	sext.w	s2,a0
      if(addr == 0)
    800032da:	06090563          	beqz	s2,80003344 <bmap+0xa2>
        return 0;
      ip->addrs[bn] = addr;
    800032de:	0524a823          	sw	s2,80(s1)
    800032e2:	a08d                	j	80003344 <bmap+0xa2>
    }
    return addr;
  }
  bn -= NDIRECT;
    800032e4:	ff45849b          	addiw	s1,a1,-12
    800032e8:	0004871b          	sext.w	a4,s1

  if(bn < NINDIRECT){
    800032ec:	0ff00793          	li	a5,255
    800032f0:	08e7e563          	bltu	a5,a4,8000337a <bmap+0xd8>
    // Load indirect block, allocating if necessary.
    if((addr = ip->addrs[NDIRECT]) == 0){
    800032f4:	08052903          	lw	s2,128(a0)
    800032f8:	00091d63          	bnez	s2,80003312 <bmap+0x70>
      addr = balloc(ip->dev);
    800032fc:	4108                	lw	a0,0(a0)
    800032fe:	00000097          	auipc	ra,0x0
    80003302:	e6c080e7          	jalr	-404(ra) # 8000316a <balloc>
    80003306:	0005091b          	sext.w	s2,a0
      if(addr == 0)
    8000330a:	02090d63          	beqz	s2,80003344 <bmap+0xa2>
        return 0;
      ip->addrs[NDIRECT] = addr;
    8000330e:	0929a023          	sw	s2,128(s3)
    }
    bp = bread(ip->dev, addr);
    80003312:	85ca                	mv	a1,s2
    80003314:	0009a503          	lw	a0,0(s3)
    80003318:	00000097          	auipc	ra,0x0
    8000331c:	b90080e7          	jalr	-1136(ra) # 80002ea8 <bread>
    80003320:	8a2a                	mv	s4,a0
    a = (uint*)bp->data;
    80003322:	05850793          	addi	a5,a0,88
    if((addr = a[bn]) == 0){
    80003326:	02049593          	slli	a1,s1,0x20
    8000332a:	9181                	srli	a1,a1,0x20
    8000332c:	058a                	slli	a1,a1,0x2
    8000332e:	00b784b3          	add	s1,a5,a1
    80003332:	0004a903          	lw	s2,0(s1)
    80003336:	02090063          	beqz	s2,80003356 <bmap+0xb4>
      if(addr){
        a[bn] = addr;
        log_write(bp);
      }
    }
    brelse(bp);
    8000333a:	8552                	mv	a0,s4
    8000333c:	00000097          	auipc	ra,0x0
    80003340:	c9c080e7          	jalr	-868(ra) # 80002fd8 <brelse>
    return addr;
  }

  panic("bmap: out of range");
}
    80003344:	854a                	mv	a0,s2
    80003346:	70a2                	ld	ra,40(sp)
    80003348:	7402                	ld	s0,32(sp)
    8000334a:	64e2                	ld	s1,24(sp)
    8000334c:	6942                	ld	s2,16(sp)
    8000334e:	69a2                	ld	s3,8(sp)
    80003350:	6a02                	ld	s4,0(sp)
    80003352:	6145                	addi	sp,sp,48
    80003354:	8082                	ret
      addr = balloc(ip->dev);
    80003356:	0009a503          	lw	a0,0(s3)
    8000335a:	00000097          	auipc	ra,0x0
    8000335e:	e10080e7          	jalr	-496(ra) # 8000316a <balloc>
    80003362:	0005091b          	sext.w	s2,a0
      if(addr){
    80003366:	fc090ae3          	beqz	s2,8000333a <bmap+0x98>
        a[bn] = addr;
    8000336a:	0124a023          	sw	s2,0(s1)
        log_write(bp);
    8000336e:	8552                	mv	a0,s4
    80003370:	00001097          	auipc	ra,0x1
    80003374:	eec080e7          	jalr	-276(ra) # 8000425c <log_write>
    80003378:	b7c9                	j	8000333a <bmap+0x98>
  panic("bmap: out of range");
    8000337a:	00005517          	auipc	a0,0x5
    8000337e:	22e50513          	addi	a0,a0,558 # 800085a8 <syscalls+0x120>
    80003382:	ffffd097          	auipc	ra,0xffffd
    80003386:	1bc080e7          	jalr	444(ra) # 8000053e <panic>

000000008000338a <iget>:
{
    8000338a:	7179                	addi	sp,sp,-48
    8000338c:	f406                	sd	ra,40(sp)
    8000338e:	f022                	sd	s0,32(sp)
    80003390:	ec26                	sd	s1,24(sp)
    80003392:	e84a                	sd	s2,16(sp)
    80003394:	e44e                	sd	s3,8(sp)
    80003396:	e052                	sd	s4,0(sp)
    80003398:	1800                	addi	s0,sp,48
    8000339a:	89aa                	mv	s3,a0
    8000339c:	8a2e                	mv	s4,a1
  acquire(&itable.lock);
    8000339e:	0001c517          	auipc	a0,0x1c
    800033a2:	cfa50513          	addi	a0,a0,-774 # 8001f098 <itable>
    800033a6:	ffffe097          	auipc	ra,0xffffe
    800033aa:	894080e7          	jalr	-1900(ra) # 80000c3a <acquire>
  empty = 0;
    800033ae:	4901                	li	s2,0
  for(ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++){
    800033b0:	0001c497          	auipc	s1,0x1c
    800033b4:	d0048493          	addi	s1,s1,-768 # 8001f0b0 <itable+0x18>
    800033b8:	0001d697          	auipc	a3,0x1d
    800033bc:	78868693          	addi	a3,a3,1928 # 80020b40 <log>
    800033c0:	a039                	j	800033ce <iget+0x44>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    800033c2:	02090b63          	beqz	s2,800033f8 <iget+0x6e>
  for(ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++){
    800033c6:	08848493          	addi	s1,s1,136
    800033ca:	02d48a63          	beq	s1,a3,800033fe <iget+0x74>
    if(ip->ref > 0 && ip->dev == dev && ip->inum == inum){
    800033ce:	449c                	lw	a5,8(s1)
    800033d0:	fef059e3          	blez	a5,800033c2 <iget+0x38>
    800033d4:	4098                	lw	a4,0(s1)
    800033d6:	ff3716e3          	bne	a4,s3,800033c2 <iget+0x38>
    800033da:	40d8                	lw	a4,4(s1)
    800033dc:	ff4713e3          	bne	a4,s4,800033c2 <iget+0x38>
      ip->ref++;
    800033e0:	2785                	addiw	a5,a5,1
    800033e2:	c49c                	sw	a5,8(s1)
      release(&itable.lock);
    800033e4:	0001c517          	auipc	a0,0x1c
    800033e8:	cb450513          	addi	a0,a0,-844 # 8001f098 <itable>
    800033ec:	ffffe097          	auipc	ra,0xffffe
    800033f0:	902080e7          	jalr	-1790(ra) # 80000cee <release>
      return ip;
    800033f4:	8926                	mv	s2,s1
    800033f6:	a03d                	j	80003424 <iget+0x9a>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    800033f8:	f7f9                	bnez	a5,800033c6 <iget+0x3c>
    800033fa:	8926                	mv	s2,s1
    800033fc:	b7e9                	j	800033c6 <iget+0x3c>
  if(empty == 0)
    800033fe:	02090c63          	beqz	s2,80003436 <iget+0xac>
  ip->dev = dev;
    80003402:	01392023          	sw	s3,0(s2)
  ip->inum = inum;
    80003406:	01492223          	sw	s4,4(s2)
  ip->ref = 1;
    8000340a:	4785                	li	a5,1
    8000340c:	00f92423          	sw	a5,8(s2)
  ip->valid = 0;
    80003410:	04092023          	sw	zero,64(s2)
  release(&itable.lock);
    80003414:	0001c517          	auipc	a0,0x1c
    80003418:	c8450513          	addi	a0,a0,-892 # 8001f098 <itable>
    8000341c:	ffffe097          	auipc	ra,0xffffe
    80003420:	8d2080e7          	jalr	-1838(ra) # 80000cee <release>
}
    80003424:	854a                	mv	a0,s2
    80003426:	70a2                	ld	ra,40(sp)
    80003428:	7402                	ld	s0,32(sp)
    8000342a:	64e2                	ld	s1,24(sp)
    8000342c:	6942                	ld	s2,16(sp)
    8000342e:	69a2                	ld	s3,8(sp)
    80003430:	6a02                	ld	s4,0(sp)
    80003432:	6145                	addi	sp,sp,48
    80003434:	8082                	ret
    panic("iget: no inodes");
    80003436:	00005517          	auipc	a0,0x5
    8000343a:	18a50513          	addi	a0,a0,394 # 800085c0 <syscalls+0x138>
    8000343e:	ffffd097          	auipc	ra,0xffffd
    80003442:	100080e7          	jalr	256(ra) # 8000053e <panic>

0000000080003446 <fsinit>:
fsinit(int dev) {
    80003446:	7179                	addi	sp,sp,-48
    80003448:	f406                	sd	ra,40(sp)
    8000344a:	f022                	sd	s0,32(sp)
    8000344c:	ec26                	sd	s1,24(sp)
    8000344e:	e84a                	sd	s2,16(sp)
    80003450:	e44e                	sd	s3,8(sp)
    80003452:	1800                	addi	s0,sp,48
    80003454:	892a                	mv	s2,a0
  bp = bread(dev, 1);
    80003456:	4585                	li	a1,1
    80003458:	00000097          	auipc	ra,0x0
    8000345c:	a50080e7          	jalr	-1456(ra) # 80002ea8 <bread>
    80003460:	84aa                	mv	s1,a0
  memmove(sb, bp->data, sizeof(*sb));
    80003462:	0001c997          	auipc	s3,0x1c
    80003466:	c1698993          	addi	s3,s3,-1002 # 8001f078 <sb>
    8000346a:	02000613          	li	a2,32
    8000346e:	05850593          	addi	a1,a0,88
    80003472:	854e                	mv	a0,s3
    80003474:	ffffe097          	auipc	ra,0xffffe
    80003478:	91e080e7          	jalr	-1762(ra) # 80000d92 <memmove>
  brelse(bp);
    8000347c:	8526                	mv	a0,s1
    8000347e:	00000097          	auipc	ra,0x0
    80003482:	b5a080e7          	jalr	-1190(ra) # 80002fd8 <brelse>
  if(sb.magic != FSMAGIC)
    80003486:	0009a703          	lw	a4,0(s3)
    8000348a:	102037b7          	lui	a5,0x10203
    8000348e:	04078793          	addi	a5,a5,64 # 10203040 <_entry-0x6fdfcfc0>
    80003492:	02f71263          	bne	a4,a5,800034b6 <fsinit+0x70>
  initlog(dev, &sb);
    80003496:	0001c597          	auipc	a1,0x1c
    8000349a:	be258593          	addi	a1,a1,-1054 # 8001f078 <sb>
    8000349e:	854a                	mv	a0,s2
    800034a0:	00001097          	auipc	ra,0x1
    800034a4:	b40080e7          	jalr	-1216(ra) # 80003fe0 <initlog>
}
    800034a8:	70a2                	ld	ra,40(sp)
    800034aa:	7402                	ld	s0,32(sp)
    800034ac:	64e2                	ld	s1,24(sp)
    800034ae:	6942                	ld	s2,16(sp)
    800034b0:	69a2                	ld	s3,8(sp)
    800034b2:	6145                	addi	sp,sp,48
    800034b4:	8082                	ret
    panic("invalid file system");
    800034b6:	00005517          	auipc	a0,0x5
    800034ba:	11a50513          	addi	a0,a0,282 # 800085d0 <syscalls+0x148>
    800034be:	ffffd097          	auipc	ra,0xffffd
    800034c2:	080080e7          	jalr	128(ra) # 8000053e <panic>

00000000800034c6 <iinit>:
{
    800034c6:	7179                	addi	sp,sp,-48
    800034c8:	f406                	sd	ra,40(sp)
    800034ca:	f022                	sd	s0,32(sp)
    800034cc:	ec26                	sd	s1,24(sp)
    800034ce:	e84a                	sd	s2,16(sp)
    800034d0:	e44e                	sd	s3,8(sp)
    800034d2:	1800                	addi	s0,sp,48
  initlock(&itable.lock, "itable");
    800034d4:	00005597          	auipc	a1,0x5
    800034d8:	11458593          	addi	a1,a1,276 # 800085e8 <syscalls+0x160>
    800034dc:	0001c517          	auipc	a0,0x1c
    800034e0:	bbc50513          	addi	a0,a0,-1092 # 8001f098 <itable>
    800034e4:	ffffd097          	auipc	ra,0xffffd
    800034e8:	6c6080e7          	jalr	1734(ra) # 80000baa <initlock>
  for(i = 0; i < NINODE; i++) {
    800034ec:	0001c497          	auipc	s1,0x1c
    800034f0:	bd448493          	addi	s1,s1,-1068 # 8001f0c0 <itable+0x28>
    800034f4:	0001d997          	auipc	s3,0x1d
    800034f8:	65c98993          	addi	s3,s3,1628 # 80020b50 <log+0x10>
    initsleeplock(&itable.inode[i].lock, "inode");
    800034fc:	00005917          	auipc	s2,0x5
    80003500:	0f490913          	addi	s2,s2,244 # 800085f0 <syscalls+0x168>
    80003504:	85ca                	mv	a1,s2
    80003506:	8526                	mv	a0,s1
    80003508:	00001097          	auipc	ra,0x1
    8000350c:	e3a080e7          	jalr	-454(ra) # 80004342 <initsleeplock>
  for(i = 0; i < NINODE; i++) {
    80003510:	08848493          	addi	s1,s1,136
    80003514:	ff3498e3          	bne	s1,s3,80003504 <iinit+0x3e>
}
    80003518:	70a2                	ld	ra,40(sp)
    8000351a:	7402                	ld	s0,32(sp)
    8000351c:	64e2                	ld	s1,24(sp)
    8000351e:	6942                	ld	s2,16(sp)
    80003520:	69a2                	ld	s3,8(sp)
    80003522:	6145                	addi	sp,sp,48
    80003524:	8082                	ret

0000000080003526 <ialloc>:
{
    80003526:	715d                	addi	sp,sp,-80
    80003528:	e486                	sd	ra,72(sp)
    8000352a:	e0a2                	sd	s0,64(sp)
    8000352c:	fc26                	sd	s1,56(sp)
    8000352e:	f84a                	sd	s2,48(sp)
    80003530:	f44e                	sd	s3,40(sp)
    80003532:	f052                	sd	s4,32(sp)
    80003534:	ec56                	sd	s5,24(sp)
    80003536:	e85a                	sd	s6,16(sp)
    80003538:	e45e                	sd	s7,8(sp)
    8000353a:	0880                	addi	s0,sp,80
  for(inum = 1; inum < sb.ninodes; inum++){
    8000353c:	0001c717          	auipc	a4,0x1c
    80003540:	b4872703          	lw	a4,-1208(a4) # 8001f084 <sb+0xc>
    80003544:	4785                	li	a5,1
    80003546:	04e7fa63          	bgeu	a5,a4,8000359a <ialloc+0x74>
    8000354a:	8aaa                	mv	s5,a0
    8000354c:	8bae                	mv	s7,a1
    8000354e:	4485                	li	s1,1
    bp = bread(dev, IBLOCK(inum, sb));
    80003550:	0001ca17          	auipc	s4,0x1c
    80003554:	b28a0a13          	addi	s4,s4,-1240 # 8001f078 <sb>
    80003558:	00048b1b          	sext.w	s6,s1
    8000355c:	0044d793          	srli	a5,s1,0x4
    80003560:	018a2583          	lw	a1,24(s4)
    80003564:	9dbd                	addw	a1,a1,a5
    80003566:	8556                	mv	a0,s5
    80003568:	00000097          	auipc	ra,0x0
    8000356c:	940080e7          	jalr	-1728(ra) # 80002ea8 <bread>
    80003570:	892a                	mv	s2,a0
    dip = (struct dinode*)bp->data + inum%IPB;
    80003572:	05850993          	addi	s3,a0,88
    80003576:	00f4f793          	andi	a5,s1,15
    8000357a:	079a                	slli	a5,a5,0x6
    8000357c:	99be                	add	s3,s3,a5
    if(dip->type == 0){  // a free inode
    8000357e:	00099783          	lh	a5,0(s3)
    80003582:	c3a1                	beqz	a5,800035c2 <ialloc+0x9c>
    brelse(bp);
    80003584:	00000097          	auipc	ra,0x0
    80003588:	a54080e7          	jalr	-1452(ra) # 80002fd8 <brelse>
  for(inum = 1; inum < sb.ninodes; inum++){
    8000358c:	0485                	addi	s1,s1,1
    8000358e:	00ca2703          	lw	a4,12(s4)
    80003592:	0004879b          	sext.w	a5,s1
    80003596:	fce7e1e3          	bltu	a5,a4,80003558 <ialloc+0x32>
  printf("ialloc: no inodes\n");
    8000359a:	00005517          	auipc	a0,0x5
    8000359e:	05e50513          	addi	a0,a0,94 # 800085f8 <syscalls+0x170>
    800035a2:	ffffd097          	auipc	ra,0xffffd
    800035a6:	fe6080e7          	jalr	-26(ra) # 80000588 <printf>
  return 0;
    800035aa:	4501                	li	a0,0
}
    800035ac:	60a6                	ld	ra,72(sp)
    800035ae:	6406                	ld	s0,64(sp)
    800035b0:	74e2                	ld	s1,56(sp)
    800035b2:	7942                	ld	s2,48(sp)
    800035b4:	79a2                	ld	s3,40(sp)
    800035b6:	7a02                	ld	s4,32(sp)
    800035b8:	6ae2                	ld	s5,24(sp)
    800035ba:	6b42                	ld	s6,16(sp)
    800035bc:	6ba2                	ld	s7,8(sp)
    800035be:	6161                	addi	sp,sp,80
    800035c0:	8082                	ret
      memset(dip, 0, sizeof(*dip));
    800035c2:	04000613          	li	a2,64
    800035c6:	4581                	li	a1,0
    800035c8:	854e                	mv	a0,s3
    800035ca:	ffffd097          	auipc	ra,0xffffd
    800035ce:	76c080e7          	jalr	1900(ra) # 80000d36 <memset>
      dip->type = type;
    800035d2:	01799023          	sh	s7,0(s3)
      log_write(bp);   // mark it allocated on the disk
    800035d6:	854a                	mv	a0,s2
    800035d8:	00001097          	auipc	ra,0x1
    800035dc:	c84080e7          	jalr	-892(ra) # 8000425c <log_write>
      brelse(bp);
    800035e0:	854a                	mv	a0,s2
    800035e2:	00000097          	auipc	ra,0x0
    800035e6:	9f6080e7          	jalr	-1546(ra) # 80002fd8 <brelse>
      return iget(dev, inum);
    800035ea:	85da                	mv	a1,s6
    800035ec:	8556                	mv	a0,s5
    800035ee:	00000097          	auipc	ra,0x0
    800035f2:	d9c080e7          	jalr	-612(ra) # 8000338a <iget>
    800035f6:	bf5d                	j	800035ac <ialloc+0x86>

00000000800035f8 <iupdate>:
{
    800035f8:	1101                	addi	sp,sp,-32
    800035fa:	ec06                	sd	ra,24(sp)
    800035fc:	e822                	sd	s0,16(sp)
    800035fe:	e426                	sd	s1,8(sp)
    80003600:	e04a                	sd	s2,0(sp)
    80003602:	1000                	addi	s0,sp,32
    80003604:	84aa                	mv	s1,a0
  bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    80003606:	415c                	lw	a5,4(a0)
    80003608:	0047d79b          	srliw	a5,a5,0x4
    8000360c:	0001c597          	auipc	a1,0x1c
    80003610:	a845a583          	lw	a1,-1404(a1) # 8001f090 <sb+0x18>
    80003614:	9dbd                	addw	a1,a1,a5
    80003616:	4108                	lw	a0,0(a0)
    80003618:	00000097          	auipc	ra,0x0
    8000361c:	890080e7          	jalr	-1904(ra) # 80002ea8 <bread>
    80003620:	892a                	mv	s2,a0
  dip = (struct dinode*)bp->data + ip->inum%IPB;
    80003622:	05850793          	addi	a5,a0,88
    80003626:	40c8                	lw	a0,4(s1)
    80003628:	893d                	andi	a0,a0,15
    8000362a:	051a                	slli	a0,a0,0x6
    8000362c:	953e                	add	a0,a0,a5
  dip->type = ip->type;
    8000362e:	04449703          	lh	a4,68(s1)
    80003632:	00e51023          	sh	a4,0(a0)
  dip->major = ip->major;
    80003636:	04649703          	lh	a4,70(s1)
    8000363a:	00e51123          	sh	a4,2(a0)
  dip->minor = ip->minor;
    8000363e:	04849703          	lh	a4,72(s1)
    80003642:	00e51223          	sh	a4,4(a0)
  dip->nlink = ip->nlink;
    80003646:	04a49703          	lh	a4,74(s1)
    8000364a:	00e51323          	sh	a4,6(a0)
  dip->size = ip->size;
    8000364e:	44f8                	lw	a4,76(s1)
    80003650:	c518                	sw	a4,8(a0)
  memmove(dip->addrs, ip->addrs, sizeof(ip->addrs));
    80003652:	03400613          	li	a2,52
    80003656:	05048593          	addi	a1,s1,80
    8000365a:	0531                	addi	a0,a0,12
    8000365c:	ffffd097          	auipc	ra,0xffffd
    80003660:	736080e7          	jalr	1846(ra) # 80000d92 <memmove>
  log_write(bp);
    80003664:	854a                	mv	a0,s2
    80003666:	00001097          	auipc	ra,0x1
    8000366a:	bf6080e7          	jalr	-1034(ra) # 8000425c <log_write>
  brelse(bp);
    8000366e:	854a                	mv	a0,s2
    80003670:	00000097          	auipc	ra,0x0
    80003674:	968080e7          	jalr	-1688(ra) # 80002fd8 <brelse>
}
    80003678:	60e2                	ld	ra,24(sp)
    8000367a:	6442                	ld	s0,16(sp)
    8000367c:	64a2                	ld	s1,8(sp)
    8000367e:	6902                	ld	s2,0(sp)
    80003680:	6105                	addi	sp,sp,32
    80003682:	8082                	ret

0000000080003684 <idup>:
{
    80003684:	1101                	addi	sp,sp,-32
    80003686:	ec06                	sd	ra,24(sp)
    80003688:	e822                	sd	s0,16(sp)
    8000368a:	e426                	sd	s1,8(sp)
    8000368c:	1000                	addi	s0,sp,32
    8000368e:	84aa                	mv	s1,a0
  acquire(&itable.lock);
    80003690:	0001c517          	auipc	a0,0x1c
    80003694:	a0850513          	addi	a0,a0,-1528 # 8001f098 <itable>
    80003698:	ffffd097          	auipc	ra,0xffffd
    8000369c:	5a2080e7          	jalr	1442(ra) # 80000c3a <acquire>
  ip->ref++;
    800036a0:	449c                	lw	a5,8(s1)
    800036a2:	2785                	addiw	a5,a5,1
    800036a4:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    800036a6:	0001c517          	auipc	a0,0x1c
    800036aa:	9f250513          	addi	a0,a0,-1550 # 8001f098 <itable>
    800036ae:	ffffd097          	auipc	ra,0xffffd
    800036b2:	640080e7          	jalr	1600(ra) # 80000cee <release>
}
    800036b6:	8526                	mv	a0,s1
    800036b8:	60e2                	ld	ra,24(sp)
    800036ba:	6442                	ld	s0,16(sp)
    800036bc:	64a2                	ld	s1,8(sp)
    800036be:	6105                	addi	sp,sp,32
    800036c0:	8082                	ret

00000000800036c2 <ilock>:
{
    800036c2:	1101                	addi	sp,sp,-32
    800036c4:	ec06                	sd	ra,24(sp)
    800036c6:	e822                	sd	s0,16(sp)
    800036c8:	e426                	sd	s1,8(sp)
    800036ca:	e04a                	sd	s2,0(sp)
    800036cc:	1000                	addi	s0,sp,32
  if(ip == 0 || ip->ref < 1)
    800036ce:	c115                	beqz	a0,800036f2 <ilock+0x30>
    800036d0:	84aa                	mv	s1,a0
    800036d2:	451c                	lw	a5,8(a0)
    800036d4:	00f05f63          	blez	a5,800036f2 <ilock+0x30>
  acquiresleep(&ip->lock);
    800036d8:	0541                	addi	a0,a0,16
    800036da:	00001097          	auipc	ra,0x1
    800036de:	ca2080e7          	jalr	-862(ra) # 8000437c <acquiresleep>
  if(ip->valid == 0){
    800036e2:	40bc                	lw	a5,64(s1)
    800036e4:	cf99                	beqz	a5,80003702 <ilock+0x40>
}
    800036e6:	60e2                	ld	ra,24(sp)
    800036e8:	6442                	ld	s0,16(sp)
    800036ea:	64a2                	ld	s1,8(sp)
    800036ec:	6902                	ld	s2,0(sp)
    800036ee:	6105                	addi	sp,sp,32
    800036f0:	8082                	ret
    panic("ilock");
    800036f2:	00005517          	auipc	a0,0x5
    800036f6:	f1e50513          	addi	a0,a0,-226 # 80008610 <syscalls+0x188>
    800036fa:	ffffd097          	auipc	ra,0xffffd
    800036fe:	e44080e7          	jalr	-444(ra) # 8000053e <panic>
    bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    80003702:	40dc                	lw	a5,4(s1)
    80003704:	0047d79b          	srliw	a5,a5,0x4
    80003708:	0001c597          	auipc	a1,0x1c
    8000370c:	9885a583          	lw	a1,-1656(a1) # 8001f090 <sb+0x18>
    80003710:	9dbd                	addw	a1,a1,a5
    80003712:	4088                	lw	a0,0(s1)
    80003714:	fffff097          	auipc	ra,0xfffff
    80003718:	794080e7          	jalr	1940(ra) # 80002ea8 <bread>
    8000371c:	892a                	mv	s2,a0
    dip = (struct dinode*)bp->data + ip->inum%IPB;
    8000371e:	05850593          	addi	a1,a0,88
    80003722:	40dc                	lw	a5,4(s1)
    80003724:	8bbd                	andi	a5,a5,15
    80003726:	079a                	slli	a5,a5,0x6
    80003728:	95be                	add	a1,a1,a5
    ip->type = dip->type;
    8000372a:	00059783          	lh	a5,0(a1)
    8000372e:	04f49223          	sh	a5,68(s1)
    ip->major = dip->major;
    80003732:	00259783          	lh	a5,2(a1)
    80003736:	04f49323          	sh	a5,70(s1)
    ip->minor = dip->minor;
    8000373a:	00459783          	lh	a5,4(a1)
    8000373e:	04f49423          	sh	a5,72(s1)
    ip->nlink = dip->nlink;
    80003742:	00659783          	lh	a5,6(a1)
    80003746:	04f49523          	sh	a5,74(s1)
    ip->size = dip->size;
    8000374a:	459c                	lw	a5,8(a1)
    8000374c:	c4fc                	sw	a5,76(s1)
    memmove(ip->addrs, dip->addrs, sizeof(ip->addrs));
    8000374e:	03400613          	li	a2,52
    80003752:	05b1                	addi	a1,a1,12
    80003754:	05048513          	addi	a0,s1,80
    80003758:	ffffd097          	auipc	ra,0xffffd
    8000375c:	63a080e7          	jalr	1594(ra) # 80000d92 <memmove>
    brelse(bp);
    80003760:	854a                	mv	a0,s2
    80003762:	00000097          	auipc	ra,0x0
    80003766:	876080e7          	jalr	-1930(ra) # 80002fd8 <brelse>
    ip->valid = 1;
    8000376a:	4785                	li	a5,1
    8000376c:	c0bc                	sw	a5,64(s1)
    if(ip->type == 0)
    8000376e:	04449783          	lh	a5,68(s1)
    80003772:	fbb5                	bnez	a5,800036e6 <ilock+0x24>
      panic("ilock: no type");
    80003774:	00005517          	auipc	a0,0x5
    80003778:	ea450513          	addi	a0,a0,-348 # 80008618 <syscalls+0x190>
    8000377c:	ffffd097          	auipc	ra,0xffffd
    80003780:	dc2080e7          	jalr	-574(ra) # 8000053e <panic>

0000000080003784 <iunlock>:
{
    80003784:	1101                	addi	sp,sp,-32
    80003786:	ec06                	sd	ra,24(sp)
    80003788:	e822                	sd	s0,16(sp)
    8000378a:	e426                	sd	s1,8(sp)
    8000378c:	e04a                	sd	s2,0(sp)
    8000378e:	1000                	addi	s0,sp,32
  if(ip == 0 || !holdingsleep(&ip->lock) || ip->ref < 1)
    80003790:	c905                	beqz	a0,800037c0 <iunlock+0x3c>
    80003792:	84aa                	mv	s1,a0
    80003794:	01050913          	addi	s2,a0,16
    80003798:	854a                	mv	a0,s2
    8000379a:	00001097          	auipc	ra,0x1
    8000379e:	c7c080e7          	jalr	-900(ra) # 80004416 <holdingsleep>
    800037a2:	cd19                	beqz	a0,800037c0 <iunlock+0x3c>
    800037a4:	449c                	lw	a5,8(s1)
    800037a6:	00f05d63          	blez	a5,800037c0 <iunlock+0x3c>
  releasesleep(&ip->lock);
    800037aa:	854a                	mv	a0,s2
    800037ac:	00001097          	auipc	ra,0x1
    800037b0:	c26080e7          	jalr	-986(ra) # 800043d2 <releasesleep>
}
    800037b4:	60e2                	ld	ra,24(sp)
    800037b6:	6442                	ld	s0,16(sp)
    800037b8:	64a2                	ld	s1,8(sp)
    800037ba:	6902                	ld	s2,0(sp)
    800037bc:	6105                	addi	sp,sp,32
    800037be:	8082                	ret
    panic("iunlock");
    800037c0:	00005517          	auipc	a0,0x5
    800037c4:	e6850513          	addi	a0,a0,-408 # 80008628 <syscalls+0x1a0>
    800037c8:	ffffd097          	auipc	ra,0xffffd
    800037cc:	d76080e7          	jalr	-650(ra) # 8000053e <panic>

00000000800037d0 <itrunc>:

// Truncate inode (discard contents).
// Caller must hold ip->lock.
void
itrunc(struct inode *ip)
{
    800037d0:	7179                	addi	sp,sp,-48
    800037d2:	f406                	sd	ra,40(sp)
    800037d4:	f022                	sd	s0,32(sp)
    800037d6:	ec26                	sd	s1,24(sp)
    800037d8:	e84a                	sd	s2,16(sp)
    800037da:	e44e                	sd	s3,8(sp)
    800037dc:	e052                	sd	s4,0(sp)
    800037de:	1800                	addi	s0,sp,48
    800037e0:	89aa                	mv	s3,a0
  int i, j;
  struct buf *bp;
  uint *a;

  for(i = 0; i < NDIRECT; i++){
    800037e2:	05050493          	addi	s1,a0,80
    800037e6:	08050913          	addi	s2,a0,128
    800037ea:	a021                	j	800037f2 <itrunc+0x22>
    800037ec:	0491                	addi	s1,s1,4
    800037ee:	01248d63          	beq	s1,s2,80003808 <itrunc+0x38>
    if(ip->addrs[i]){
    800037f2:	408c                	lw	a1,0(s1)
    800037f4:	dde5                	beqz	a1,800037ec <itrunc+0x1c>
      bfree(ip->dev, ip->addrs[i]);
    800037f6:	0009a503          	lw	a0,0(s3)
    800037fa:	00000097          	auipc	ra,0x0
    800037fe:	8f4080e7          	jalr	-1804(ra) # 800030ee <bfree>
      ip->addrs[i] = 0;
    80003802:	0004a023          	sw	zero,0(s1)
    80003806:	b7dd                	j	800037ec <itrunc+0x1c>
    }
  }

  if(ip->addrs[NDIRECT]){
    80003808:	0809a583          	lw	a1,128(s3)
    8000380c:	e185                	bnez	a1,8000382c <itrunc+0x5c>
    brelse(bp);
    bfree(ip->dev, ip->addrs[NDIRECT]);
    ip->addrs[NDIRECT] = 0;
  }

  ip->size = 0;
    8000380e:	0409a623          	sw	zero,76(s3)
  iupdate(ip);
    80003812:	854e                	mv	a0,s3
    80003814:	00000097          	auipc	ra,0x0
    80003818:	de4080e7          	jalr	-540(ra) # 800035f8 <iupdate>
}
    8000381c:	70a2                	ld	ra,40(sp)
    8000381e:	7402                	ld	s0,32(sp)
    80003820:	64e2                	ld	s1,24(sp)
    80003822:	6942                	ld	s2,16(sp)
    80003824:	69a2                	ld	s3,8(sp)
    80003826:	6a02                	ld	s4,0(sp)
    80003828:	6145                	addi	sp,sp,48
    8000382a:	8082                	ret
    bp = bread(ip->dev, ip->addrs[NDIRECT]);
    8000382c:	0009a503          	lw	a0,0(s3)
    80003830:	fffff097          	auipc	ra,0xfffff
    80003834:	678080e7          	jalr	1656(ra) # 80002ea8 <bread>
    80003838:	8a2a                	mv	s4,a0
    for(j = 0; j < NINDIRECT; j++){
    8000383a:	05850493          	addi	s1,a0,88
    8000383e:	45850913          	addi	s2,a0,1112
    80003842:	a021                	j	8000384a <itrunc+0x7a>
    80003844:	0491                	addi	s1,s1,4
    80003846:	01248b63          	beq	s1,s2,8000385c <itrunc+0x8c>
      if(a[j])
    8000384a:	408c                	lw	a1,0(s1)
    8000384c:	dde5                	beqz	a1,80003844 <itrunc+0x74>
        bfree(ip->dev, a[j]);
    8000384e:	0009a503          	lw	a0,0(s3)
    80003852:	00000097          	auipc	ra,0x0
    80003856:	89c080e7          	jalr	-1892(ra) # 800030ee <bfree>
    8000385a:	b7ed                	j	80003844 <itrunc+0x74>
    brelse(bp);
    8000385c:	8552                	mv	a0,s4
    8000385e:	fffff097          	auipc	ra,0xfffff
    80003862:	77a080e7          	jalr	1914(ra) # 80002fd8 <brelse>
    bfree(ip->dev, ip->addrs[NDIRECT]);
    80003866:	0809a583          	lw	a1,128(s3)
    8000386a:	0009a503          	lw	a0,0(s3)
    8000386e:	00000097          	auipc	ra,0x0
    80003872:	880080e7          	jalr	-1920(ra) # 800030ee <bfree>
    ip->addrs[NDIRECT] = 0;
    80003876:	0809a023          	sw	zero,128(s3)
    8000387a:	bf51                	j	8000380e <itrunc+0x3e>

000000008000387c <iput>:
{
    8000387c:	1101                	addi	sp,sp,-32
    8000387e:	ec06                	sd	ra,24(sp)
    80003880:	e822                	sd	s0,16(sp)
    80003882:	e426                	sd	s1,8(sp)
    80003884:	e04a                	sd	s2,0(sp)
    80003886:	1000                	addi	s0,sp,32
    80003888:	84aa                	mv	s1,a0
  acquire(&itable.lock);
    8000388a:	0001c517          	auipc	a0,0x1c
    8000388e:	80e50513          	addi	a0,a0,-2034 # 8001f098 <itable>
    80003892:	ffffd097          	auipc	ra,0xffffd
    80003896:	3a8080e7          	jalr	936(ra) # 80000c3a <acquire>
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    8000389a:	4498                	lw	a4,8(s1)
    8000389c:	4785                	li	a5,1
    8000389e:	02f70363          	beq	a4,a5,800038c4 <iput+0x48>
  ip->ref--;
    800038a2:	449c                	lw	a5,8(s1)
    800038a4:	37fd                	addiw	a5,a5,-1
    800038a6:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    800038a8:	0001b517          	auipc	a0,0x1b
    800038ac:	7f050513          	addi	a0,a0,2032 # 8001f098 <itable>
    800038b0:	ffffd097          	auipc	ra,0xffffd
    800038b4:	43e080e7          	jalr	1086(ra) # 80000cee <release>
}
    800038b8:	60e2                	ld	ra,24(sp)
    800038ba:	6442                	ld	s0,16(sp)
    800038bc:	64a2                	ld	s1,8(sp)
    800038be:	6902                	ld	s2,0(sp)
    800038c0:	6105                	addi	sp,sp,32
    800038c2:	8082                	ret
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    800038c4:	40bc                	lw	a5,64(s1)
    800038c6:	dff1                	beqz	a5,800038a2 <iput+0x26>
    800038c8:	04a49783          	lh	a5,74(s1)
    800038cc:	fbf9                	bnez	a5,800038a2 <iput+0x26>
    acquiresleep(&ip->lock);
    800038ce:	01048913          	addi	s2,s1,16
    800038d2:	854a                	mv	a0,s2
    800038d4:	00001097          	auipc	ra,0x1
    800038d8:	aa8080e7          	jalr	-1368(ra) # 8000437c <acquiresleep>
    release(&itable.lock);
    800038dc:	0001b517          	auipc	a0,0x1b
    800038e0:	7bc50513          	addi	a0,a0,1980 # 8001f098 <itable>
    800038e4:	ffffd097          	auipc	ra,0xffffd
    800038e8:	40a080e7          	jalr	1034(ra) # 80000cee <release>
    itrunc(ip);
    800038ec:	8526                	mv	a0,s1
    800038ee:	00000097          	auipc	ra,0x0
    800038f2:	ee2080e7          	jalr	-286(ra) # 800037d0 <itrunc>
    ip->type = 0;
    800038f6:	04049223          	sh	zero,68(s1)
    iupdate(ip);
    800038fa:	8526                	mv	a0,s1
    800038fc:	00000097          	auipc	ra,0x0
    80003900:	cfc080e7          	jalr	-772(ra) # 800035f8 <iupdate>
    ip->valid = 0;
    80003904:	0404a023          	sw	zero,64(s1)
    releasesleep(&ip->lock);
    80003908:	854a                	mv	a0,s2
    8000390a:	00001097          	auipc	ra,0x1
    8000390e:	ac8080e7          	jalr	-1336(ra) # 800043d2 <releasesleep>
    acquire(&itable.lock);
    80003912:	0001b517          	auipc	a0,0x1b
    80003916:	78650513          	addi	a0,a0,1926 # 8001f098 <itable>
    8000391a:	ffffd097          	auipc	ra,0xffffd
    8000391e:	320080e7          	jalr	800(ra) # 80000c3a <acquire>
    80003922:	b741                	j	800038a2 <iput+0x26>

0000000080003924 <iunlockput>:
{
    80003924:	1101                	addi	sp,sp,-32
    80003926:	ec06                	sd	ra,24(sp)
    80003928:	e822                	sd	s0,16(sp)
    8000392a:	e426                	sd	s1,8(sp)
    8000392c:	1000                	addi	s0,sp,32
    8000392e:	84aa                	mv	s1,a0
  iunlock(ip);
    80003930:	00000097          	auipc	ra,0x0
    80003934:	e54080e7          	jalr	-428(ra) # 80003784 <iunlock>
  iput(ip);
    80003938:	8526                	mv	a0,s1
    8000393a:	00000097          	auipc	ra,0x0
    8000393e:	f42080e7          	jalr	-190(ra) # 8000387c <iput>
}
    80003942:	60e2                	ld	ra,24(sp)
    80003944:	6442                	ld	s0,16(sp)
    80003946:	64a2                	ld	s1,8(sp)
    80003948:	6105                	addi	sp,sp,32
    8000394a:	8082                	ret

000000008000394c <stati>:

// Copy stat information from inode.
// Caller must hold ip->lock.
void
stati(struct inode *ip, struct stat *st)
{
    8000394c:	1141                	addi	sp,sp,-16
    8000394e:	e422                	sd	s0,8(sp)
    80003950:	0800                	addi	s0,sp,16
  st->dev = ip->dev;
    80003952:	411c                	lw	a5,0(a0)
    80003954:	c19c                	sw	a5,0(a1)
  st->ino = ip->inum;
    80003956:	415c                	lw	a5,4(a0)
    80003958:	c1dc                	sw	a5,4(a1)
  st->type = ip->type;
    8000395a:	04451783          	lh	a5,68(a0)
    8000395e:	00f59423          	sh	a5,8(a1)
  st->nlink = ip->nlink;
    80003962:	04a51783          	lh	a5,74(a0)
    80003966:	00f59523          	sh	a5,10(a1)
  st->size = ip->size;
    8000396a:	04c56783          	lwu	a5,76(a0)
    8000396e:	e99c                	sd	a5,16(a1)
}
    80003970:	6422                	ld	s0,8(sp)
    80003972:	0141                	addi	sp,sp,16
    80003974:	8082                	ret

0000000080003976 <readi>:
readi(struct inode *ip, int user_dst, uint64 dst, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    80003976:	457c                	lw	a5,76(a0)
    80003978:	0ed7e963          	bltu	a5,a3,80003a6a <readi+0xf4>
{
    8000397c:	7159                	addi	sp,sp,-112
    8000397e:	f486                	sd	ra,104(sp)
    80003980:	f0a2                	sd	s0,96(sp)
    80003982:	eca6                	sd	s1,88(sp)
    80003984:	e8ca                	sd	s2,80(sp)
    80003986:	e4ce                	sd	s3,72(sp)
    80003988:	e0d2                	sd	s4,64(sp)
    8000398a:	fc56                	sd	s5,56(sp)
    8000398c:	f85a                	sd	s6,48(sp)
    8000398e:	f45e                	sd	s7,40(sp)
    80003990:	f062                	sd	s8,32(sp)
    80003992:	ec66                	sd	s9,24(sp)
    80003994:	e86a                	sd	s10,16(sp)
    80003996:	e46e                	sd	s11,8(sp)
    80003998:	1880                	addi	s0,sp,112
    8000399a:	8b2a                	mv	s6,a0
    8000399c:	8bae                	mv	s7,a1
    8000399e:	8a32                	mv	s4,a2
    800039a0:	84b6                	mv	s1,a3
    800039a2:	8aba                	mv	s5,a4
  if(off > ip->size || off + n < off)
    800039a4:	9f35                	addw	a4,a4,a3
    return 0;
    800039a6:	4501                	li	a0,0
  if(off > ip->size || off + n < off)
    800039a8:	0ad76063          	bltu	a4,a3,80003a48 <readi+0xd2>
  if(off + n > ip->size)
    800039ac:	00e7f463          	bgeu	a5,a4,800039b4 <readi+0x3e>
    n = ip->size - off;
    800039b0:	40d78abb          	subw	s5,a5,a3

  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    800039b4:	0a0a8963          	beqz	s5,80003a66 <readi+0xf0>
    800039b8:	4981                	li	s3,0
    uint addr = bmap(ip, off/BSIZE);
    if(addr == 0)
      break;
    bp = bread(ip->dev, addr);
    m = min(n - tot, BSIZE - off%BSIZE);
    800039ba:	40000c93          	li	s9,1024
    if(either_copyout(user_dst, dst, bp->data + (off % BSIZE), m) == -1) {
    800039be:	5c7d                	li	s8,-1
    800039c0:	a82d                	j	800039fa <readi+0x84>
    800039c2:	020d1d93          	slli	s11,s10,0x20
    800039c6:	020ddd93          	srli	s11,s11,0x20
    800039ca:	05890793          	addi	a5,s2,88
    800039ce:	86ee                	mv	a3,s11
    800039d0:	963e                	add	a2,a2,a5
    800039d2:	85d2                	mv	a1,s4
    800039d4:	855e                	mv	a0,s7
    800039d6:	fffff097          	auipc	ra,0xfffff
    800039da:	b04080e7          	jalr	-1276(ra) # 800024da <either_copyout>
    800039de:	05850d63          	beq	a0,s8,80003a38 <readi+0xc2>
      brelse(bp);
      tot = -1;
      break;
    }
    brelse(bp);
    800039e2:	854a                	mv	a0,s2
    800039e4:	fffff097          	auipc	ra,0xfffff
    800039e8:	5f4080e7          	jalr	1524(ra) # 80002fd8 <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    800039ec:	013d09bb          	addw	s3,s10,s3
    800039f0:	009d04bb          	addw	s1,s10,s1
    800039f4:	9a6e                	add	s4,s4,s11
    800039f6:	0559f763          	bgeu	s3,s5,80003a44 <readi+0xce>
    uint addr = bmap(ip, off/BSIZE);
    800039fa:	00a4d59b          	srliw	a1,s1,0xa
    800039fe:	855a                	mv	a0,s6
    80003a00:	00000097          	auipc	ra,0x0
    80003a04:	8a2080e7          	jalr	-1886(ra) # 800032a2 <bmap>
    80003a08:	0005059b          	sext.w	a1,a0
    if(addr == 0)
    80003a0c:	cd85                	beqz	a1,80003a44 <readi+0xce>
    bp = bread(ip->dev, addr);
    80003a0e:	000b2503          	lw	a0,0(s6)
    80003a12:	fffff097          	auipc	ra,0xfffff
    80003a16:	496080e7          	jalr	1174(ra) # 80002ea8 <bread>
    80003a1a:	892a                	mv	s2,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    80003a1c:	3ff4f613          	andi	a2,s1,1023
    80003a20:	40cc87bb          	subw	a5,s9,a2
    80003a24:	413a873b          	subw	a4,s5,s3
    80003a28:	8d3e                	mv	s10,a5
    80003a2a:	2781                	sext.w	a5,a5
    80003a2c:	0007069b          	sext.w	a3,a4
    80003a30:	f8f6f9e3          	bgeu	a3,a5,800039c2 <readi+0x4c>
    80003a34:	8d3a                	mv	s10,a4
    80003a36:	b771                	j	800039c2 <readi+0x4c>
      brelse(bp);
    80003a38:	854a                	mv	a0,s2
    80003a3a:	fffff097          	auipc	ra,0xfffff
    80003a3e:	59e080e7          	jalr	1438(ra) # 80002fd8 <brelse>
      tot = -1;
    80003a42:	59fd                	li	s3,-1
  }
  return tot;
    80003a44:	0009851b          	sext.w	a0,s3
}
    80003a48:	70a6                	ld	ra,104(sp)
    80003a4a:	7406                	ld	s0,96(sp)
    80003a4c:	64e6                	ld	s1,88(sp)
    80003a4e:	6946                	ld	s2,80(sp)
    80003a50:	69a6                	ld	s3,72(sp)
    80003a52:	6a06                	ld	s4,64(sp)
    80003a54:	7ae2                	ld	s5,56(sp)
    80003a56:	7b42                	ld	s6,48(sp)
    80003a58:	7ba2                	ld	s7,40(sp)
    80003a5a:	7c02                	ld	s8,32(sp)
    80003a5c:	6ce2                	ld	s9,24(sp)
    80003a5e:	6d42                	ld	s10,16(sp)
    80003a60:	6da2                	ld	s11,8(sp)
    80003a62:	6165                	addi	sp,sp,112
    80003a64:	8082                	ret
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80003a66:	89d6                	mv	s3,s5
    80003a68:	bff1                	j	80003a44 <readi+0xce>
    return 0;
    80003a6a:	4501                	li	a0,0
}
    80003a6c:	8082                	ret

0000000080003a6e <writei>:
writei(struct inode *ip, int user_src, uint64 src, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    80003a6e:	457c                	lw	a5,76(a0)
    80003a70:	10d7e863          	bltu	a5,a3,80003b80 <writei+0x112>
{
    80003a74:	7159                	addi	sp,sp,-112
    80003a76:	f486                	sd	ra,104(sp)
    80003a78:	f0a2                	sd	s0,96(sp)
    80003a7a:	eca6                	sd	s1,88(sp)
    80003a7c:	e8ca                	sd	s2,80(sp)
    80003a7e:	e4ce                	sd	s3,72(sp)
    80003a80:	e0d2                	sd	s4,64(sp)
    80003a82:	fc56                	sd	s5,56(sp)
    80003a84:	f85a                	sd	s6,48(sp)
    80003a86:	f45e                	sd	s7,40(sp)
    80003a88:	f062                	sd	s8,32(sp)
    80003a8a:	ec66                	sd	s9,24(sp)
    80003a8c:	e86a                	sd	s10,16(sp)
    80003a8e:	e46e                	sd	s11,8(sp)
    80003a90:	1880                	addi	s0,sp,112
    80003a92:	8aaa                	mv	s5,a0
    80003a94:	8bae                	mv	s7,a1
    80003a96:	8a32                	mv	s4,a2
    80003a98:	8936                	mv	s2,a3
    80003a9a:	8b3a                	mv	s6,a4
  if(off > ip->size || off + n < off)
    80003a9c:	00e687bb          	addw	a5,a3,a4
    80003aa0:	0ed7e263          	bltu	a5,a3,80003b84 <writei+0x116>
    return -1;
  if(off + n > MAXFILE*BSIZE)
    80003aa4:	00043737          	lui	a4,0x43
    80003aa8:	0ef76063          	bltu	a4,a5,80003b88 <writei+0x11a>
    return -1;

  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80003aac:	0c0b0863          	beqz	s6,80003b7c <writei+0x10e>
    80003ab0:	4981                	li	s3,0
    uint addr = bmap(ip, off/BSIZE);
    if(addr == 0)
      break;
    bp = bread(ip->dev, addr);
    m = min(n - tot, BSIZE - off%BSIZE);
    80003ab2:	40000c93          	li	s9,1024
    if(either_copyin(bp->data + (off % BSIZE), user_src, src, m) == -1) {
    80003ab6:	5c7d                	li	s8,-1
    80003ab8:	a091                	j	80003afc <writei+0x8e>
    80003aba:	020d1d93          	slli	s11,s10,0x20
    80003abe:	020ddd93          	srli	s11,s11,0x20
    80003ac2:	05848793          	addi	a5,s1,88
    80003ac6:	86ee                	mv	a3,s11
    80003ac8:	8652                	mv	a2,s4
    80003aca:	85de                	mv	a1,s7
    80003acc:	953e                	add	a0,a0,a5
    80003ace:	fffff097          	auipc	ra,0xfffff
    80003ad2:	a62080e7          	jalr	-1438(ra) # 80002530 <either_copyin>
    80003ad6:	07850263          	beq	a0,s8,80003b3a <writei+0xcc>
      brelse(bp);
      break;
    }
    log_write(bp);
    80003ada:	8526                	mv	a0,s1
    80003adc:	00000097          	auipc	ra,0x0
    80003ae0:	780080e7          	jalr	1920(ra) # 8000425c <log_write>
    brelse(bp);
    80003ae4:	8526                	mv	a0,s1
    80003ae6:	fffff097          	auipc	ra,0xfffff
    80003aea:	4f2080e7          	jalr	1266(ra) # 80002fd8 <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80003aee:	013d09bb          	addw	s3,s10,s3
    80003af2:	012d093b          	addw	s2,s10,s2
    80003af6:	9a6e                	add	s4,s4,s11
    80003af8:	0569f663          	bgeu	s3,s6,80003b44 <writei+0xd6>
    uint addr = bmap(ip, off/BSIZE);
    80003afc:	00a9559b          	srliw	a1,s2,0xa
    80003b00:	8556                	mv	a0,s5
    80003b02:	fffff097          	auipc	ra,0xfffff
    80003b06:	7a0080e7          	jalr	1952(ra) # 800032a2 <bmap>
    80003b0a:	0005059b          	sext.w	a1,a0
    if(addr == 0)
    80003b0e:	c99d                	beqz	a1,80003b44 <writei+0xd6>
    bp = bread(ip->dev, addr);
    80003b10:	000aa503          	lw	a0,0(s5)
    80003b14:	fffff097          	auipc	ra,0xfffff
    80003b18:	394080e7          	jalr	916(ra) # 80002ea8 <bread>
    80003b1c:	84aa                	mv	s1,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    80003b1e:	3ff97513          	andi	a0,s2,1023
    80003b22:	40ac87bb          	subw	a5,s9,a0
    80003b26:	413b073b          	subw	a4,s6,s3
    80003b2a:	8d3e                	mv	s10,a5
    80003b2c:	2781                	sext.w	a5,a5
    80003b2e:	0007069b          	sext.w	a3,a4
    80003b32:	f8f6f4e3          	bgeu	a3,a5,80003aba <writei+0x4c>
    80003b36:	8d3a                	mv	s10,a4
    80003b38:	b749                	j	80003aba <writei+0x4c>
      brelse(bp);
    80003b3a:	8526                	mv	a0,s1
    80003b3c:	fffff097          	auipc	ra,0xfffff
    80003b40:	49c080e7          	jalr	1180(ra) # 80002fd8 <brelse>
  }

  if(off > ip->size)
    80003b44:	04caa783          	lw	a5,76(s5)
    80003b48:	0127f463          	bgeu	a5,s2,80003b50 <writei+0xe2>
    ip->size = off;
    80003b4c:	052aa623          	sw	s2,76(s5)

  // write the i-node back to disk even if the size didn't change
  // because the loop above might have called bmap() and added a new
  // block to ip->addrs[].
  iupdate(ip);
    80003b50:	8556                	mv	a0,s5
    80003b52:	00000097          	auipc	ra,0x0
    80003b56:	aa6080e7          	jalr	-1370(ra) # 800035f8 <iupdate>

  return tot;
    80003b5a:	0009851b          	sext.w	a0,s3
}
    80003b5e:	70a6                	ld	ra,104(sp)
    80003b60:	7406                	ld	s0,96(sp)
    80003b62:	64e6                	ld	s1,88(sp)
    80003b64:	6946                	ld	s2,80(sp)
    80003b66:	69a6                	ld	s3,72(sp)
    80003b68:	6a06                	ld	s4,64(sp)
    80003b6a:	7ae2                	ld	s5,56(sp)
    80003b6c:	7b42                	ld	s6,48(sp)
    80003b6e:	7ba2                	ld	s7,40(sp)
    80003b70:	7c02                	ld	s8,32(sp)
    80003b72:	6ce2                	ld	s9,24(sp)
    80003b74:	6d42                	ld	s10,16(sp)
    80003b76:	6da2                	ld	s11,8(sp)
    80003b78:	6165                	addi	sp,sp,112
    80003b7a:	8082                	ret
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80003b7c:	89da                	mv	s3,s6
    80003b7e:	bfc9                	j	80003b50 <writei+0xe2>
    return -1;
    80003b80:	557d                	li	a0,-1
}
    80003b82:	8082                	ret
    return -1;
    80003b84:	557d                	li	a0,-1
    80003b86:	bfe1                	j	80003b5e <writei+0xf0>
    return -1;
    80003b88:	557d                	li	a0,-1
    80003b8a:	bfd1                	j	80003b5e <writei+0xf0>

0000000080003b8c <namecmp>:

// Directories

int
namecmp(const char *s, const char *t)
{
    80003b8c:	1141                	addi	sp,sp,-16
    80003b8e:	e406                	sd	ra,8(sp)
    80003b90:	e022                	sd	s0,0(sp)
    80003b92:	0800                	addi	s0,sp,16
  return strncmp(s, t, DIRSIZ);
    80003b94:	4639                	li	a2,14
    80003b96:	ffffd097          	auipc	ra,0xffffd
    80003b9a:	270080e7          	jalr	624(ra) # 80000e06 <strncmp>
}
    80003b9e:	60a2                	ld	ra,8(sp)
    80003ba0:	6402                	ld	s0,0(sp)
    80003ba2:	0141                	addi	sp,sp,16
    80003ba4:	8082                	ret

0000000080003ba6 <dirlookup>:

// Look for a directory entry in a directory.
// If found, set *poff to byte offset of entry.
struct inode*
dirlookup(struct inode *dp, char *name, uint *poff)
{
    80003ba6:	7139                	addi	sp,sp,-64
    80003ba8:	fc06                	sd	ra,56(sp)
    80003baa:	f822                	sd	s0,48(sp)
    80003bac:	f426                	sd	s1,40(sp)
    80003bae:	f04a                	sd	s2,32(sp)
    80003bb0:	ec4e                	sd	s3,24(sp)
    80003bb2:	e852                	sd	s4,16(sp)
    80003bb4:	0080                	addi	s0,sp,64
  uint off, inum;
  struct dirent de;

  if(dp->type != T_DIR)
    80003bb6:	04451703          	lh	a4,68(a0)
    80003bba:	4785                	li	a5,1
    80003bbc:	00f71a63          	bne	a4,a5,80003bd0 <dirlookup+0x2a>
    80003bc0:	892a                	mv	s2,a0
    80003bc2:	89ae                	mv	s3,a1
    80003bc4:	8a32                	mv	s4,a2
    panic("dirlookup not DIR");

  for(off = 0; off < dp->size; off += sizeof(de)){
    80003bc6:	457c                	lw	a5,76(a0)
    80003bc8:	4481                	li	s1,0
      inum = de.inum;
      return iget(dp->dev, inum);
    }
  }

  return 0;
    80003bca:	4501                	li	a0,0
  for(off = 0; off < dp->size; off += sizeof(de)){
    80003bcc:	e79d                	bnez	a5,80003bfa <dirlookup+0x54>
    80003bce:	a8a5                	j	80003c46 <dirlookup+0xa0>
    panic("dirlookup not DIR");
    80003bd0:	00005517          	auipc	a0,0x5
    80003bd4:	a6050513          	addi	a0,a0,-1440 # 80008630 <syscalls+0x1a8>
    80003bd8:	ffffd097          	auipc	ra,0xffffd
    80003bdc:	966080e7          	jalr	-1690(ra) # 8000053e <panic>
      panic("dirlookup read");
    80003be0:	00005517          	auipc	a0,0x5
    80003be4:	a6850513          	addi	a0,a0,-1432 # 80008648 <syscalls+0x1c0>
    80003be8:	ffffd097          	auipc	ra,0xffffd
    80003bec:	956080e7          	jalr	-1706(ra) # 8000053e <panic>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80003bf0:	24c1                	addiw	s1,s1,16
    80003bf2:	04c92783          	lw	a5,76(s2)
    80003bf6:	04f4f763          	bgeu	s1,a5,80003c44 <dirlookup+0x9e>
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80003bfa:	4741                	li	a4,16
    80003bfc:	86a6                	mv	a3,s1
    80003bfe:	fc040613          	addi	a2,s0,-64
    80003c02:	4581                	li	a1,0
    80003c04:	854a                	mv	a0,s2
    80003c06:	00000097          	auipc	ra,0x0
    80003c0a:	d70080e7          	jalr	-656(ra) # 80003976 <readi>
    80003c0e:	47c1                	li	a5,16
    80003c10:	fcf518e3          	bne	a0,a5,80003be0 <dirlookup+0x3a>
    if(de.inum == 0)
    80003c14:	fc045783          	lhu	a5,-64(s0)
    80003c18:	dfe1                	beqz	a5,80003bf0 <dirlookup+0x4a>
    if(namecmp(name, de.name) == 0){
    80003c1a:	fc240593          	addi	a1,s0,-62
    80003c1e:	854e                	mv	a0,s3
    80003c20:	00000097          	auipc	ra,0x0
    80003c24:	f6c080e7          	jalr	-148(ra) # 80003b8c <namecmp>
    80003c28:	f561                	bnez	a0,80003bf0 <dirlookup+0x4a>
      if(poff)
    80003c2a:	000a0463          	beqz	s4,80003c32 <dirlookup+0x8c>
        *poff = off;
    80003c2e:	009a2023          	sw	s1,0(s4)
      return iget(dp->dev, inum);
    80003c32:	fc045583          	lhu	a1,-64(s0)
    80003c36:	00092503          	lw	a0,0(s2)
    80003c3a:	fffff097          	auipc	ra,0xfffff
    80003c3e:	750080e7          	jalr	1872(ra) # 8000338a <iget>
    80003c42:	a011                	j	80003c46 <dirlookup+0xa0>
  return 0;
    80003c44:	4501                	li	a0,0
}
    80003c46:	70e2                	ld	ra,56(sp)
    80003c48:	7442                	ld	s0,48(sp)
    80003c4a:	74a2                	ld	s1,40(sp)
    80003c4c:	7902                	ld	s2,32(sp)
    80003c4e:	69e2                	ld	s3,24(sp)
    80003c50:	6a42                	ld	s4,16(sp)
    80003c52:	6121                	addi	sp,sp,64
    80003c54:	8082                	ret

0000000080003c56 <namex>:
// If parent != 0, return the inode for the parent and copy the final
// path element into name, which must have room for DIRSIZ bytes.
// Must be called inside a transaction since it calls iput().
static struct inode*
namex(char *path, int nameiparent, char *name)
{
    80003c56:	711d                	addi	sp,sp,-96
    80003c58:	ec86                	sd	ra,88(sp)
    80003c5a:	e8a2                	sd	s0,80(sp)
    80003c5c:	e4a6                	sd	s1,72(sp)
    80003c5e:	e0ca                	sd	s2,64(sp)
    80003c60:	fc4e                	sd	s3,56(sp)
    80003c62:	f852                	sd	s4,48(sp)
    80003c64:	f456                	sd	s5,40(sp)
    80003c66:	f05a                	sd	s6,32(sp)
    80003c68:	ec5e                	sd	s7,24(sp)
    80003c6a:	e862                	sd	s8,16(sp)
    80003c6c:	e466                	sd	s9,8(sp)
    80003c6e:	1080                	addi	s0,sp,96
    80003c70:	84aa                	mv	s1,a0
    80003c72:	8aae                	mv	s5,a1
    80003c74:	8a32                	mv	s4,a2
  struct inode *ip, *next;

  if(*path == '/')
    80003c76:	00054703          	lbu	a4,0(a0)
    80003c7a:	02f00793          	li	a5,47
    80003c7e:	02f70363          	beq	a4,a5,80003ca4 <namex+0x4e>
    ip = iget(ROOTDEV, ROOTINO);
  else
    ip = idup(myproc()->cwd);
    80003c82:	ffffe097          	auipc	ra,0xffffe
    80003c86:	da8080e7          	jalr	-600(ra) # 80001a2a <myproc>
    80003c8a:	15053503          	ld	a0,336(a0)
    80003c8e:	00000097          	auipc	ra,0x0
    80003c92:	9f6080e7          	jalr	-1546(ra) # 80003684 <idup>
    80003c96:	89aa                	mv	s3,a0
  while(*path == '/')
    80003c98:	02f00913          	li	s2,47
  len = path - s;
    80003c9c:	4b01                	li	s6,0
  if(len >= DIRSIZ)
    80003c9e:	4c35                	li	s8,13

  while((path = skipelem(path, name)) != 0){
    ilock(ip);
    if(ip->type != T_DIR){
    80003ca0:	4b85                	li	s7,1
    80003ca2:	a865                	j	80003d5a <namex+0x104>
    ip = iget(ROOTDEV, ROOTINO);
    80003ca4:	4585                	li	a1,1
    80003ca6:	4505                	li	a0,1
    80003ca8:	fffff097          	auipc	ra,0xfffff
    80003cac:	6e2080e7          	jalr	1762(ra) # 8000338a <iget>
    80003cb0:	89aa                	mv	s3,a0
    80003cb2:	b7dd                	j	80003c98 <namex+0x42>
      iunlockput(ip);
    80003cb4:	854e                	mv	a0,s3
    80003cb6:	00000097          	auipc	ra,0x0
    80003cba:	c6e080e7          	jalr	-914(ra) # 80003924 <iunlockput>
      return 0;
    80003cbe:	4981                	li	s3,0
  if(nameiparent){
    iput(ip);
    return 0;
  }
  return ip;
}
    80003cc0:	854e                	mv	a0,s3
    80003cc2:	60e6                	ld	ra,88(sp)
    80003cc4:	6446                	ld	s0,80(sp)
    80003cc6:	64a6                	ld	s1,72(sp)
    80003cc8:	6906                	ld	s2,64(sp)
    80003cca:	79e2                	ld	s3,56(sp)
    80003ccc:	7a42                	ld	s4,48(sp)
    80003cce:	7aa2                	ld	s5,40(sp)
    80003cd0:	7b02                	ld	s6,32(sp)
    80003cd2:	6be2                	ld	s7,24(sp)
    80003cd4:	6c42                	ld	s8,16(sp)
    80003cd6:	6ca2                	ld	s9,8(sp)
    80003cd8:	6125                	addi	sp,sp,96
    80003cda:	8082                	ret
      iunlock(ip);
    80003cdc:	854e                	mv	a0,s3
    80003cde:	00000097          	auipc	ra,0x0
    80003ce2:	aa6080e7          	jalr	-1370(ra) # 80003784 <iunlock>
      return ip;
    80003ce6:	bfe9                	j	80003cc0 <namex+0x6a>
      iunlockput(ip);
    80003ce8:	854e                	mv	a0,s3
    80003cea:	00000097          	auipc	ra,0x0
    80003cee:	c3a080e7          	jalr	-966(ra) # 80003924 <iunlockput>
      return 0;
    80003cf2:	89e6                	mv	s3,s9
    80003cf4:	b7f1                	j	80003cc0 <namex+0x6a>
  len = path - s;
    80003cf6:	40b48633          	sub	a2,s1,a1
    80003cfa:	00060c9b          	sext.w	s9,a2
  if(len >= DIRSIZ)
    80003cfe:	099c5463          	bge	s8,s9,80003d86 <namex+0x130>
    memmove(name, s, DIRSIZ);
    80003d02:	4639                	li	a2,14
    80003d04:	8552                	mv	a0,s4
    80003d06:	ffffd097          	auipc	ra,0xffffd
    80003d0a:	08c080e7          	jalr	140(ra) # 80000d92 <memmove>
  while(*path == '/')
    80003d0e:	0004c783          	lbu	a5,0(s1)
    80003d12:	01279763          	bne	a5,s2,80003d20 <namex+0xca>
    path++;
    80003d16:	0485                	addi	s1,s1,1
  while(*path == '/')
    80003d18:	0004c783          	lbu	a5,0(s1)
    80003d1c:	ff278de3          	beq	a5,s2,80003d16 <namex+0xc0>
    ilock(ip);
    80003d20:	854e                	mv	a0,s3
    80003d22:	00000097          	auipc	ra,0x0
    80003d26:	9a0080e7          	jalr	-1632(ra) # 800036c2 <ilock>
    if(ip->type != T_DIR){
    80003d2a:	04499783          	lh	a5,68(s3)
    80003d2e:	f97793e3          	bne	a5,s7,80003cb4 <namex+0x5e>
    if(nameiparent && *path == '\0'){
    80003d32:	000a8563          	beqz	s5,80003d3c <namex+0xe6>
    80003d36:	0004c783          	lbu	a5,0(s1)
    80003d3a:	d3cd                	beqz	a5,80003cdc <namex+0x86>
    if((next = dirlookup(ip, name, 0)) == 0){
    80003d3c:	865a                	mv	a2,s6
    80003d3e:	85d2                	mv	a1,s4
    80003d40:	854e                	mv	a0,s3
    80003d42:	00000097          	auipc	ra,0x0
    80003d46:	e64080e7          	jalr	-412(ra) # 80003ba6 <dirlookup>
    80003d4a:	8caa                	mv	s9,a0
    80003d4c:	dd51                	beqz	a0,80003ce8 <namex+0x92>
    iunlockput(ip);
    80003d4e:	854e                	mv	a0,s3
    80003d50:	00000097          	auipc	ra,0x0
    80003d54:	bd4080e7          	jalr	-1068(ra) # 80003924 <iunlockput>
    ip = next;
    80003d58:	89e6                	mv	s3,s9
  while(*path == '/')
    80003d5a:	0004c783          	lbu	a5,0(s1)
    80003d5e:	05279763          	bne	a5,s2,80003dac <namex+0x156>
    path++;
    80003d62:	0485                	addi	s1,s1,1
  while(*path == '/')
    80003d64:	0004c783          	lbu	a5,0(s1)
    80003d68:	ff278de3          	beq	a5,s2,80003d62 <namex+0x10c>
  if(*path == 0)
    80003d6c:	c79d                	beqz	a5,80003d9a <namex+0x144>
    path++;
    80003d6e:	85a6                	mv	a1,s1
  len = path - s;
    80003d70:	8cda                	mv	s9,s6
    80003d72:	865a                	mv	a2,s6
  while(*path != '/' && *path != 0)
    80003d74:	01278963          	beq	a5,s2,80003d86 <namex+0x130>
    80003d78:	dfbd                	beqz	a5,80003cf6 <namex+0xa0>
    path++;
    80003d7a:	0485                	addi	s1,s1,1
  while(*path != '/' && *path != 0)
    80003d7c:	0004c783          	lbu	a5,0(s1)
    80003d80:	ff279ce3          	bne	a5,s2,80003d78 <namex+0x122>
    80003d84:	bf8d                	j	80003cf6 <namex+0xa0>
    memmove(name, s, len);
    80003d86:	2601                	sext.w	a2,a2
    80003d88:	8552                	mv	a0,s4
    80003d8a:	ffffd097          	auipc	ra,0xffffd
    80003d8e:	008080e7          	jalr	8(ra) # 80000d92 <memmove>
    name[len] = 0;
    80003d92:	9cd2                	add	s9,s9,s4
    80003d94:	000c8023          	sb	zero,0(s9) # 2000 <_entry-0x7fffe000>
    80003d98:	bf9d                	j	80003d0e <namex+0xb8>
  if(nameiparent){
    80003d9a:	f20a83e3          	beqz	s5,80003cc0 <namex+0x6a>
    iput(ip);
    80003d9e:	854e                	mv	a0,s3
    80003da0:	00000097          	auipc	ra,0x0
    80003da4:	adc080e7          	jalr	-1316(ra) # 8000387c <iput>
    return 0;
    80003da8:	4981                	li	s3,0
    80003daa:	bf19                	j	80003cc0 <namex+0x6a>
  if(*path == 0)
    80003dac:	d7fd                	beqz	a5,80003d9a <namex+0x144>
  while(*path != '/' && *path != 0)
    80003dae:	0004c783          	lbu	a5,0(s1)
    80003db2:	85a6                	mv	a1,s1
    80003db4:	b7d1                	j	80003d78 <namex+0x122>

0000000080003db6 <dirlink>:
{
    80003db6:	7139                	addi	sp,sp,-64
    80003db8:	fc06                	sd	ra,56(sp)
    80003dba:	f822                	sd	s0,48(sp)
    80003dbc:	f426                	sd	s1,40(sp)
    80003dbe:	f04a                	sd	s2,32(sp)
    80003dc0:	ec4e                	sd	s3,24(sp)
    80003dc2:	e852                	sd	s4,16(sp)
    80003dc4:	0080                	addi	s0,sp,64
    80003dc6:	892a                	mv	s2,a0
    80003dc8:	8a2e                	mv	s4,a1
    80003dca:	89b2                	mv	s3,a2
  if((ip = dirlookup(dp, name, 0)) != 0){
    80003dcc:	4601                	li	a2,0
    80003dce:	00000097          	auipc	ra,0x0
    80003dd2:	dd8080e7          	jalr	-552(ra) # 80003ba6 <dirlookup>
    80003dd6:	e93d                	bnez	a0,80003e4c <dirlink+0x96>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80003dd8:	04c92483          	lw	s1,76(s2)
    80003ddc:	c49d                	beqz	s1,80003e0a <dirlink+0x54>
    80003dde:	4481                	li	s1,0
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80003de0:	4741                	li	a4,16
    80003de2:	86a6                	mv	a3,s1
    80003de4:	fc040613          	addi	a2,s0,-64
    80003de8:	4581                	li	a1,0
    80003dea:	854a                	mv	a0,s2
    80003dec:	00000097          	auipc	ra,0x0
    80003df0:	b8a080e7          	jalr	-1142(ra) # 80003976 <readi>
    80003df4:	47c1                	li	a5,16
    80003df6:	06f51163          	bne	a0,a5,80003e58 <dirlink+0xa2>
    if(de.inum == 0)
    80003dfa:	fc045783          	lhu	a5,-64(s0)
    80003dfe:	c791                	beqz	a5,80003e0a <dirlink+0x54>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80003e00:	24c1                	addiw	s1,s1,16
    80003e02:	04c92783          	lw	a5,76(s2)
    80003e06:	fcf4ede3          	bltu	s1,a5,80003de0 <dirlink+0x2a>
  strncpy(de.name, name, DIRSIZ);
    80003e0a:	4639                	li	a2,14
    80003e0c:	85d2                	mv	a1,s4
    80003e0e:	fc240513          	addi	a0,s0,-62
    80003e12:	ffffd097          	auipc	ra,0xffffd
    80003e16:	030080e7          	jalr	48(ra) # 80000e42 <strncpy>
  de.inum = inum;
    80003e1a:	fd341023          	sh	s3,-64(s0)
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80003e1e:	4741                	li	a4,16
    80003e20:	86a6                	mv	a3,s1
    80003e22:	fc040613          	addi	a2,s0,-64
    80003e26:	4581                	li	a1,0
    80003e28:	854a                	mv	a0,s2
    80003e2a:	00000097          	auipc	ra,0x0
    80003e2e:	c44080e7          	jalr	-956(ra) # 80003a6e <writei>
    80003e32:	1541                	addi	a0,a0,-16
    80003e34:	00a03533          	snez	a0,a0
    80003e38:	40a00533          	neg	a0,a0
}
    80003e3c:	70e2                	ld	ra,56(sp)
    80003e3e:	7442                	ld	s0,48(sp)
    80003e40:	74a2                	ld	s1,40(sp)
    80003e42:	7902                	ld	s2,32(sp)
    80003e44:	69e2                	ld	s3,24(sp)
    80003e46:	6a42                	ld	s4,16(sp)
    80003e48:	6121                	addi	sp,sp,64
    80003e4a:	8082                	ret
    iput(ip);
    80003e4c:	00000097          	auipc	ra,0x0
    80003e50:	a30080e7          	jalr	-1488(ra) # 8000387c <iput>
    return -1;
    80003e54:	557d                	li	a0,-1
    80003e56:	b7dd                	j	80003e3c <dirlink+0x86>
      panic("dirlink read");
    80003e58:	00005517          	auipc	a0,0x5
    80003e5c:	80050513          	addi	a0,a0,-2048 # 80008658 <syscalls+0x1d0>
    80003e60:	ffffc097          	auipc	ra,0xffffc
    80003e64:	6de080e7          	jalr	1758(ra) # 8000053e <panic>

0000000080003e68 <namei>:

struct inode*
namei(char *path)
{
    80003e68:	1101                	addi	sp,sp,-32
    80003e6a:	ec06                	sd	ra,24(sp)
    80003e6c:	e822                	sd	s0,16(sp)
    80003e6e:	1000                	addi	s0,sp,32
  char name[DIRSIZ];
  return namex(path, 0, name);
    80003e70:	fe040613          	addi	a2,s0,-32
    80003e74:	4581                	li	a1,0
    80003e76:	00000097          	auipc	ra,0x0
    80003e7a:	de0080e7          	jalr	-544(ra) # 80003c56 <namex>
}
    80003e7e:	60e2                	ld	ra,24(sp)
    80003e80:	6442                	ld	s0,16(sp)
    80003e82:	6105                	addi	sp,sp,32
    80003e84:	8082                	ret

0000000080003e86 <nameiparent>:

struct inode*
nameiparent(char *path, char *name)
{
    80003e86:	1141                	addi	sp,sp,-16
    80003e88:	e406                	sd	ra,8(sp)
    80003e8a:	e022                	sd	s0,0(sp)
    80003e8c:	0800                	addi	s0,sp,16
    80003e8e:	862e                	mv	a2,a1
  return namex(path, 1, name);
    80003e90:	4585                	li	a1,1
    80003e92:	00000097          	auipc	ra,0x0
    80003e96:	dc4080e7          	jalr	-572(ra) # 80003c56 <namex>
}
    80003e9a:	60a2                	ld	ra,8(sp)
    80003e9c:	6402                	ld	s0,0(sp)
    80003e9e:	0141                	addi	sp,sp,16
    80003ea0:	8082                	ret

0000000080003ea2 <write_head>:
// Write in-memory log header to disk.
// This is the true point at which the
// current transaction commits.
static void
write_head(void)
{
    80003ea2:	1101                	addi	sp,sp,-32
    80003ea4:	ec06                	sd	ra,24(sp)
    80003ea6:	e822                	sd	s0,16(sp)
    80003ea8:	e426                	sd	s1,8(sp)
    80003eaa:	e04a                	sd	s2,0(sp)
    80003eac:	1000                	addi	s0,sp,32
  struct buf *buf = bread(log.dev, log.start);
    80003eae:	0001d917          	auipc	s2,0x1d
    80003eb2:	c9290913          	addi	s2,s2,-878 # 80020b40 <log>
    80003eb6:	01892583          	lw	a1,24(s2)
    80003eba:	02892503          	lw	a0,40(s2)
    80003ebe:	fffff097          	auipc	ra,0xfffff
    80003ec2:	fea080e7          	jalr	-22(ra) # 80002ea8 <bread>
    80003ec6:	84aa                	mv	s1,a0
  struct logheader *hb = (struct logheader *) (buf->data);
  int i;
  hb->n = log.lh.n;
    80003ec8:	02c92683          	lw	a3,44(s2)
    80003ecc:	cd34                	sw	a3,88(a0)
  for (i = 0; i < log.lh.n; i++) {
    80003ece:	02d05763          	blez	a3,80003efc <write_head+0x5a>
    80003ed2:	0001d797          	auipc	a5,0x1d
    80003ed6:	c9e78793          	addi	a5,a5,-866 # 80020b70 <log+0x30>
    80003eda:	05c50713          	addi	a4,a0,92
    80003ede:	36fd                	addiw	a3,a3,-1
    80003ee0:	1682                	slli	a3,a3,0x20
    80003ee2:	9281                	srli	a3,a3,0x20
    80003ee4:	068a                	slli	a3,a3,0x2
    80003ee6:	0001d617          	auipc	a2,0x1d
    80003eea:	c8e60613          	addi	a2,a2,-882 # 80020b74 <log+0x34>
    80003eee:	96b2                	add	a3,a3,a2
    hb->block[i] = log.lh.block[i];
    80003ef0:	4390                	lw	a2,0(a5)
    80003ef2:	c310                	sw	a2,0(a4)
  for (i = 0; i < log.lh.n; i++) {
    80003ef4:	0791                	addi	a5,a5,4
    80003ef6:	0711                	addi	a4,a4,4
    80003ef8:	fed79ce3          	bne	a5,a3,80003ef0 <write_head+0x4e>
  }
  bwrite(buf);
    80003efc:	8526                	mv	a0,s1
    80003efe:	fffff097          	auipc	ra,0xfffff
    80003f02:	09c080e7          	jalr	156(ra) # 80002f9a <bwrite>
  brelse(buf);
    80003f06:	8526                	mv	a0,s1
    80003f08:	fffff097          	auipc	ra,0xfffff
    80003f0c:	0d0080e7          	jalr	208(ra) # 80002fd8 <brelse>
}
    80003f10:	60e2                	ld	ra,24(sp)
    80003f12:	6442                	ld	s0,16(sp)
    80003f14:	64a2                	ld	s1,8(sp)
    80003f16:	6902                	ld	s2,0(sp)
    80003f18:	6105                	addi	sp,sp,32
    80003f1a:	8082                	ret

0000000080003f1c <install_trans>:
  for (tail = 0; tail < log.lh.n; tail++) {
    80003f1c:	0001d797          	auipc	a5,0x1d
    80003f20:	c507a783          	lw	a5,-944(a5) # 80020b6c <log+0x2c>
    80003f24:	0af05d63          	blez	a5,80003fde <install_trans+0xc2>
{
    80003f28:	7139                	addi	sp,sp,-64
    80003f2a:	fc06                	sd	ra,56(sp)
    80003f2c:	f822                	sd	s0,48(sp)
    80003f2e:	f426                	sd	s1,40(sp)
    80003f30:	f04a                	sd	s2,32(sp)
    80003f32:	ec4e                	sd	s3,24(sp)
    80003f34:	e852                	sd	s4,16(sp)
    80003f36:	e456                	sd	s5,8(sp)
    80003f38:	e05a                	sd	s6,0(sp)
    80003f3a:	0080                	addi	s0,sp,64
    80003f3c:	8b2a                	mv	s6,a0
    80003f3e:	0001da97          	auipc	s5,0x1d
    80003f42:	c32a8a93          	addi	s5,s5,-974 # 80020b70 <log+0x30>
  for (tail = 0; tail < log.lh.n; tail++) {
    80003f46:	4a01                	li	s4,0
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
    80003f48:	0001d997          	auipc	s3,0x1d
    80003f4c:	bf898993          	addi	s3,s3,-1032 # 80020b40 <log>
    80003f50:	a00d                	j	80003f72 <install_trans+0x56>
    brelse(lbuf);
    80003f52:	854a                	mv	a0,s2
    80003f54:	fffff097          	auipc	ra,0xfffff
    80003f58:	084080e7          	jalr	132(ra) # 80002fd8 <brelse>
    brelse(dbuf);
    80003f5c:	8526                	mv	a0,s1
    80003f5e:	fffff097          	auipc	ra,0xfffff
    80003f62:	07a080e7          	jalr	122(ra) # 80002fd8 <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    80003f66:	2a05                	addiw	s4,s4,1
    80003f68:	0a91                	addi	s5,s5,4
    80003f6a:	02c9a783          	lw	a5,44(s3)
    80003f6e:	04fa5e63          	bge	s4,a5,80003fca <install_trans+0xae>
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
    80003f72:	0189a583          	lw	a1,24(s3)
    80003f76:	014585bb          	addw	a1,a1,s4
    80003f7a:	2585                	addiw	a1,a1,1
    80003f7c:	0289a503          	lw	a0,40(s3)
    80003f80:	fffff097          	auipc	ra,0xfffff
    80003f84:	f28080e7          	jalr	-216(ra) # 80002ea8 <bread>
    80003f88:	892a                	mv	s2,a0
    struct buf *dbuf = bread(log.dev, log.lh.block[tail]); // read dst
    80003f8a:	000aa583          	lw	a1,0(s5)
    80003f8e:	0289a503          	lw	a0,40(s3)
    80003f92:	fffff097          	auipc	ra,0xfffff
    80003f96:	f16080e7          	jalr	-234(ra) # 80002ea8 <bread>
    80003f9a:	84aa                	mv	s1,a0
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
    80003f9c:	40000613          	li	a2,1024
    80003fa0:	05890593          	addi	a1,s2,88
    80003fa4:	05850513          	addi	a0,a0,88
    80003fa8:	ffffd097          	auipc	ra,0xffffd
    80003fac:	dea080e7          	jalr	-534(ra) # 80000d92 <memmove>
    bwrite(dbuf);  // write dst to disk
    80003fb0:	8526                	mv	a0,s1
    80003fb2:	fffff097          	auipc	ra,0xfffff
    80003fb6:	fe8080e7          	jalr	-24(ra) # 80002f9a <bwrite>
    if(recovering == 0)
    80003fba:	f80b1ce3          	bnez	s6,80003f52 <install_trans+0x36>
      bunpin(dbuf);
    80003fbe:	8526                	mv	a0,s1
    80003fc0:	fffff097          	auipc	ra,0xfffff
    80003fc4:	0f2080e7          	jalr	242(ra) # 800030b2 <bunpin>
    80003fc8:	b769                	j	80003f52 <install_trans+0x36>
}
    80003fca:	70e2                	ld	ra,56(sp)
    80003fcc:	7442                	ld	s0,48(sp)
    80003fce:	74a2                	ld	s1,40(sp)
    80003fd0:	7902                	ld	s2,32(sp)
    80003fd2:	69e2                	ld	s3,24(sp)
    80003fd4:	6a42                	ld	s4,16(sp)
    80003fd6:	6aa2                	ld	s5,8(sp)
    80003fd8:	6b02                	ld	s6,0(sp)
    80003fda:	6121                	addi	sp,sp,64
    80003fdc:	8082                	ret
    80003fde:	8082                	ret

0000000080003fe0 <initlog>:
{
    80003fe0:	7179                	addi	sp,sp,-48
    80003fe2:	f406                	sd	ra,40(sp)
    80003fe4:	f022                	sd	s0,32(sp)
    80003fe6:	ec26                	sd	s1,24(sp)
    80003fe8:	e84a                	sd	s2,16(sp)
    80003fea:	e44e                	sd	s3,8(sp)
    80003fec:	1800                	addi	s0,sp,48
    80003fee:	892a                	mv	s2,a0
    80003ff0:	89ae                	mv	s3,a1
  initlock(&log.lock, "log");
    80003ff2:	0001d497          	auipc	s1,0x1d
    80003ff6:	b4e48493          	addi	s1,s1,-1202 # 80020b40 <log>
    80003ffa:	00004597          	auipc	a1,0x4
    80003ffe:	66e58593          	addi	a1,a1,1646 # 80008668 <syscalls+0x1e0>
    80004002:	8526                	mv	a0,s1
    80004004:	ffffd097          	auipc	ra,0xffffd
    80004008:	ba6080e7          	jalr	-1114(ra) # 80000baa <initlock>
  log.start = sb->logstart;
    8000400c:	0149a583          	lw	a1,20(s3)
    80004010:	cc8c                	sw	a1,24(s1)
  log.size = sb->nlog;
    80004012:	0109a783          	lw	a5,16(s3)
    80004016:	ccdc                	sw	a5,28(s1)
  log.dev = dev;
    80004018:	0324a423          	sw	s2,40(s1)
  struct buf *buf = bread(log.dev, log.start);
    8000401c:	854a                	mv	a0,s2
    8000401e:	fffff097          	auipc	ra,0xfffff
    80004022:	e8a080e7          	jalr	-374(ra) # 80002ea8 <bread>
  log.lh.n = lh->n;
    80004026:	4d34                	lw	a3,88(a0)
    80004028:	d4d4                	sw	a3,44(s1)
  for (i = 0; i < log.lh.n; i++) {
    8000402a:	02d05563          	blez	a3,80004054 <initlog+0x74>
    8000402e:	05c50793          	addi	a5,a0,92
    80004032:	0001d717          	auipc	a4,0x1d
    80004036:	b3e70713          	addi	a4,a4,-1218 # 80020b70 <log+0x30>
    8000403a:	36fd                	addiw	a3,a3,-1
    8000403c:	1682                	slli	a3,a3,0x20
    8000403e:	9281                	srli	a3,a3,0x20
    80004040:	068a                	slli	a3,a3,0x2
    80004042:	06050613          	addi	a2,a0,96
    80004046:	96b2                	add	a3,a3,a2
    log.lh.block[i] = lh->block[i];
    80004048:	4390                	lw	a2,0(a5)
    8000404a:	c310                	sw	a2,0(a4)
  for (i = 0; i < log.lh.n; i++) {
    8000404c:	0791                	addi	a5,a5,4
    8000404e:	0711                	addi	a4,a4,4
    80004050:	fed79ce3          	bne	a5,a3,80004048 <initlog+0x68>
  brelse(buf);
    80004054:	fffff097          	auipc	ra,0xfffff
    80004058:	f84080e7          	jalr	-124(ra) # 80002fd8 <brelse>

static void
recover_from_log(void)
{
  read_head();
  install_trans(1); // if committed, copy from log to disk
    8000405c:	4505                	li	a0,1
    8000405e:	00000097          	auipc	ra,0x0
    80004062:	ebe080e7          	jalr	-322(ra) # 80003f1c <install_trans>
  log.lh.n = 0;
    80004066:	0001d797          	auipc	a5,0x1d
    8000406a:	b007a323          	sw	zero,-1274(a5) # 80020b6c <log+0x2c>
  write_head(); // clear the log
    8000406e:	00000097          	auipc	ra,0x0
    80004072:	e34080e7          	jalr	-460(ra) # 80003ea2 <write_head>
}
    80004076:	70a2                	ld	ra,40(sp)
    80004078:	7402                	ld	s0,32(sp)
    8000407a:	64e2                	ld	s1,24(sp)
    8000407c:	6942                	ld	s2,16(sp)
    8000407e:	69a2                	ld	s3,8(sp)
    80004080:	6145                	addi	sp,sp,48
    80004082:	8082                	ret

0000000080004084 <begin_op>:
}

// called at the start of each FS system call.
void
begin_op(void)
{
    80004084:	1101                	addi	sp,sp,-32
    80004086:	ec06                	sd	ra,24(sp)
    80004088:	e822                	sd	s0,16(sp)
    8000408a:	e426                	sd	s1,8(sp)
    8000408c:	e04a                	sd	s2,0(sp)
    8000408e:	1000                	addi	s0,sp,32
  acquire(&log.lock);
    80004090:	0001d517          	auipc	a0,0x1d
    80004094:	ab050513          	addi	a0,a0,-1360 # 80020b40 <log>
    80004098:	ffffd097          	auipc	ra,0xffffd
    8000409c:	ba2080e7          	jalr	-1118(ra) # 80000c3a <acquire>
  while(1){
    if(log.committing){
    800040a0:	0001d497          	auipc	s1,0x1d
    800040a4:	aa048493          	addi	s1,s1,-1376 # 80020b40 <log>
      sleep(&log, &log.lock);
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
    800040a8:	4979                	li	s2,30
    800040aa:	a039                	j	800040b8 <begin_op+0x34>
      sleep(&log, &log.lock);
    800040ac:	85a6                	mv	a1,s1
    800040ae:	8526                	mv	a0,s1
    800040b0:	ffffe097          	auipc	ra,0xffffe
    800040b4:	022080e7          	jalr	34(ra) # 800020d2 <sleep>
    if(log.committing){
    800040b8:	50dc                	lw	a5,36(s1)
    800040ba:	fbed                	bnez	a5,800040ac <begin_op+0x28>
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
    800040bc:	509c                	lw	a5,32(s1)
    800040be:	0017871b          	addiw	a4,a5,1
    800040c2:	0007069b          	sext.w	a3,a4
    800040c6:	0027179b          	slliw	a5,a4,0x2
    800040ca:	9fb9                	addw	a5,a5,a4
    800040cc:	0017979b          	slliw	a5,a5,0x1
    800040d0:	54d8                	lw	a4,44(s1)
    800040d2:	9fb9                	addw	a5,a5,a4
    800040d4:	00f95963          	bge	s2,a5,800040e6 <begin_op+0x62>
      // this op might exhaust log space; wait for commit.
      sleep(&log, &log.lock);
    800040d8:	85a6                	mv	a1,s1
    800040da:	8526                	mv	a0,s1
    800040dc:	ffffe097          	auipc	ra,0xffffe
    800040e0:	ff6080e7          	jalr	-10(ra) # 800020d2 <sleep>
    800040e4:	bfd1                	j	800040b8 <begin_op+0x34>
    } else {
      log.outstanding += 1;
    800040e6:	0001d517          	auipc	a0,0x1d
    800040ea:	a5a50513          	addi	a0,a0,-1446 # 80020b40 <log>
    800040ee:	d114                	sw	a3,32(a0)
      release(&log.lock);
    800040f0:	ffffd097          	auipc	ra,0xffffd
    800040f4:	bfe080e7          	jalr	-1026(ra) # 80000cee <release>
      break;
    }
  }
}
    800040f8:	60e2                	ld	ra,24(sp)
    800040fa:	6442                	ld	s0,16(sp)
    800040fc:	64a2                	ld	s1,8(sp)
    800040fe:	6902                	ld	s2,0(sp)
    80004100:	6105                	addi	sp,sp,32
    80004102:	8082                	ret

0000000080004104 <end_op>:

// called at the end of each FS system call.
// commits if this was the last outstanding operation.
void
end_op(void)
{
    80004104:	7139                	addi	sp,sp,-64
    80004106:	fc06                	sd	ra,56(sp)
    80004108:	f822                	sd	s0,48(sp)
    8000410a:	f426                	sd	s1,40(sp)
    8000410c:	f04a                	sd	s2,32(sp)
    8000410e:	ec4e                	sd	s3,24(sp)
    80004110:	e852                	sd	s4,16(sp)
    80004112:	e456                	sd	s5,8(sp)
    80004114:	0080                	addi	s0,sp,64
  int do_commit = 0;

  acquire(&log.lock);
    80004116:	0001d497          	auipc	s1,0x1d
    8000411a:	a2a48493          	addi	s1,s1,-1494 # 80020b40 <log>
    8000411e:	8526                	mv	a0,s1
    80004120:	ffffd097          	auipc	ra,0xffffd
    80004124:	b1a080e7          	jalr	-1254(ra) # 80000c3a <acquire>
  log.outstanding -= 1;
    80004128:	509c                	lw	a5,32(s1)
    8000412a:	37fd                	addiw	a5,a5,-1
    8000412c:	0007891b          	sext.w	s2,a5
    80004130:	d09c                	sw	a5,32(s1)
  if(log.committing)
    80004132:	50dc                	lw	a5,36(s1)
    80004134:	e7b9                	bnez	a5,80004182 <end_op+0x7e>
    panic("log.committing");
  if(log.outstanding == 0){
    80004136:	04091e63          	bnez	s2,80004192 <end_op+0x8e>
    do_commit = 1;
    log.committing = 1;
    8000413a:	0001d497          	auipc	s1,0x1d
    8000413e:	a0648493          	addi	s1,s1,-1530 # 80020b40 <log>
    80004142:	4785                	li	a5,1
    80004144:	d0dc                	sw	a5,36(s1)
    // begin_op() may be waiting for log space,
    // and decrementing log.outstanding has decreased
    // the amount of reserved space.
    wakeup(&log);
  }
  release(&log.lock);
    80004146:	8526                	mv	a0,s1
    80004148:	ffffd097          	auipc	ra,0xffffd
    8000414c:	ba6080e7          	jalr	-1114(ra) # 80000cee <release>
}

static void
commit()
{
  if (log.lh.n > 0) {
    80004150:	54dc                	lw	a5,44(s1)
    80004152:	06f04763          	bgtz	a5,800041c0 <end_op+0xbc>
    acquire(&log.lock);
    80004156:	0001d497          	auipc	s1,0x1d
    8000415a:	9ea48493          	addi	s1,s1,-1558 # 80020b40 <log>
    8000415e:	8526                	mv	a0,s1
    80004160:	ffffd097          	auipc	ra,0xffffd
    80004164:	ada080e7          	jalr	-1318(ra) # 80000c3a <acquire>
    log.committing = 0;
    80004168:	0204a223          	sw	zero,36(s1)
    wakeup(&log);
    8000416c:	8526                	mv	a0,s1
    8000416e:	ffffe097          	auipc	ra,0xffffe
    80004172:	fc8080e7          	jalr	-56(ra) # 80002136 <wakeup>
    release(&log.lock);
    80004176:	8526                	mv	a0,s1
    80004178:	ffffd097          	auipc	ra,0xffffd
    8000417c:	b76080e7          	jalr	-1162(ra) # 80000cee <release>
}
    80004180:	a03d                	j	800041ae <end_op+0xaa>
    panic("log.committing");
    80004182:	00004517          	auipc	a0,0x4
    80004186:	4ee50513          	addi	a0,a0,1262 # 80008670 <syscalls+0x1e8>
    8000418a:	ffffc097          	auipc	ra,0xffffc
    8000418e:	3b4080e7          	jalr	948(ra) # 8000053e <panic>
    wakeup(&log);
    80004192:	0001d497          	auipc	s1,0x1d
    80004196:	9ae48493          	addi	s1,s1,-1618 # 80020b40 <log>
    8000419a:	8526                	mv	a0,s1
    8000419c:	ffffe097          	auipc	ra,0xffffe
    800041a0:	f9a080e7          	jalr	-102(ra) # 80002136 <wakeup>
  release(&log.lock);
    800041a4:	8526                	mv	a0,s1
    800041a6:	ffffd097          	auipc	ra,0xffffd
    800041aa:	b48080e7          	jalr	-1208(ra) # 80000cee <release>
}
    800041ae:	70e2                	ld	ra,56(sp)
    800041b0:	7442                	ld	s0,48(sp)
    800041b2:	74a2                	ld	s1,40(sp)
    800041b4:	7902                	ld	s2,32(sp)
    800041b6:	69e2                	ld	s3,24(sp)
    800041b8:	6a42                	ld	s4,16(sp)
    800041ba:	6aa2                	ld	s5,8(sp)
    800041bc:	6121                	addi	sp,sp,64
    800041be:	8082                	ret
  for (tail = 0; tail < log.lh.n; tail++) {
    800041c0:	0001da97          	auipc	s5,0x1d
    800041c4:	9b0a8a93          	addi	s5,s5,-1616 # 80020b70 <log+0x30>
    struct buf *to = bread(log.dev, log.start+tail+1); // log block
    800041c8:	0001da17          	auipc	s4,0x1d
    800041cc:	978a0a13          	addi	s4,s4,-1672 # 80020b40 <log>
    800041d0:	018a2583          	lw	a1,24(s4)
    800041d4:	012585bb          	addw	a1,a1,s2
    800041d8:	2585                	addiw	a1,a1,1
    800041da:	028a2503          	lw	a0,40(s4)
    800041de:	fffff097          	auipc	ra,0xfffff
    800041e2:	cca080e7          	jalr	-822(ra) # 80002ea8 <bread>
    800041e6:	84aa                	mv	s1,a0
    struct buf *from = bread(log.dev, log.lh.block[tail]); // cache block
    800041e8:	000aa583          	lw	a1,0(s5)
    800041ec:	028a2503          	lw	a0,40(s4)
    800041f0:	fffff097          	auipc	ra,0xfffff
    800041f4:	cb8080e7          	jalr	-840(ra) # 80002ea8 <bread>
    800041f8:	89aa                	mv	s3,a0
    memmove(to->data, from->data, BSIZE);
    800041fa:	40000613          	li	a2,1024
    800041fe:	05850593          	addi	a1,a0,88
    80004202:	05848513          	addi	a0,s1,88
    80004206:	ffffd097          	auipc	ra,0xffffd
    8000420a:	b8c080e7          	jalr	-1140(ra) # 80000d92 <memmove>
    bwrite(to);  // write the log
    8000420e:	8526                	mv	a0,s1
    80004210:	fffff097          	auipc	ra,0xfffff
    80004214:	d8a080e7          	jalr	-630(ra) # 80002f9a <bwrite>
    brelse(from);
    80004218:	854e                	mv	a0,s3
    8000421a:	fffff097          	auipc	ra,0xfffff
    8000421e:	dbe080e7          	jalr	-578(ra) # 80002fd8 <brelse>
    brelse(to);
    80004222:	8526                	mv	a0,s1
    80004224:	fffff097          	auipc	ra,0xfffff
    80004228:	db4080e7          	jalr	-588(ra) # 80002fd8 <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    8000422c:	2905                	addiw	s2,s2,1
    8000422e:	0a91                	addi	s5,s5,4
    80004230:	02ca2783          	lw	a5,44(s4)
    80004234:	f8f94ee3          	blt	s2,a5,800041d0 <end_op+0xcc>
    write_log();     // Write modified blocks from cache to log
    write_head();    // Write header to disk -- the real commit
    80004238:	00000097          	auipc	ra,0x0
    8000423c:	c6a080e7          	jalr	-918(ra) # 80003ea2 <write_head>
    install_trans(0); // Now install writes to home locations
    80004240:	4501                	li	a0,0
    80004242:	00000097          	auipc	ra,0x0
    80004246:	cda080e7          	jalr	-806(ra) # 80003f1c <install_trans>
    log.lh.n = 0;
    8000424a:	0001d797          	auipc	a5,0x1d
    8000424e:	9207a123          	sw	zero,-1758(a5) # 80020b6c <log+0x2c>
    write_head();    // Erase the transaction from the log
    80004252:	00000097          	auipc	ra,0x0
    80004256:	c50080e7          	jalr	-944(ra) # 80003ea2 <write_head>
    8000425a:	bdf5                	j	80004156 <end_op+0x52>

000000008000425c <log_write>:
//   modify bp->data[]
//   log_write(bp)
//   brelse(bp)
void
log_write(struct buf *b)
{
    8000425c:	1101                	addi	sp,sp,-32
    8000425e:	ec06                	sd	ra,24(sp)
    80004260:	e822                	sd	s0,16(sp)
    80004262:	e426                	sd	s1,8(sp)
    80004264:	e04a                	sd	s2,0(sp)
    80004266:	1000                	addi	s0,sp,32
    80004268:	84aa                	mv	s1,a0
  int i;

  acquire(&log.lock);
    8000426a:	0001d917          	auipc	s2,0x1d
    8000426e:	8d690913          	addi	s2,s2,-1834 # 80020b40 <log>
    80004272:	854a                	mv	a0,s2
    80004274:	ffffd097          	auipc	ra,0xffffd
    80004278:	9c6080e7          	jalr	-1594(ra) # 80000c3a <acquire>
  if (log.lh.n >= LOGSIZE || log.lh.n >= log.size - 1)
    8000427c:	02c92603          	lw	a2,44(s2)
    80004280:	47f5                	li	a5,29
    80004282:	06c7c563          	blt	a5,a2,800042ec <log_write+0x90>
    80004286:	0001d797          	auipc	a5,0x1d
    8000428a:	8d67a783          	lw	a5,-1834(a5) # 80020b5c <log+0x1c>
    8000428e:	37fd                	addiw	a5,a5,-1
    80004290:	04f65e63          	bge	a2,a5,800042ec <log_write+0x90>
    panic("too big a transaction");
  if (log.outstanding < 1)
    80004294:	0001d797          	auipc	a5,0x1d
    80004298:	8cc7a783          	lw	a5,-1844(a5) # 80020b60 <log+0x20>
    8000429c:	06f05063          	blez	a5,800042fc <log_write+0xa0>
    panic("log_write outside of trans");

  for (i = 0; i < log.lh.n; i++) {
    800042a0:	4781                	li	a5,0
    800042a2:	06c05563          	blez	a2,8000430c <log_write+0xb0>
    if (log.lh.block[i] == b->blockno)   // log absorption
    800042a6:	44cc                	lw	a1,12(s1)
    800042a8:	0001d717          	auipc	a4,0x1d
    800042ac:	8c870713          	addi	a4,a4,-1848 # 80020b70 <log+0x30>
  for (i = 0; i < log.lh.n; i++) {
    800042b0:	4781                	li	a5,0
    if (log.lh.block[i] == b->blockno)   // log absorption
    800042b2:	4314                	lw	a3,0(a4)
    800042b4:	04b68c63          	beq	a3,a1,8000430c <log_write+0xb0>
  for (i = 0; i < log.lh.n; i++) {
    800042b8:	2785                	addiw	a5,a5,1
    800042ba:	0711                	addi	a4,a4,4
    800042bc:	fef61be3          	bne	a2,a5,800042b2 <log_write+0x56>
      break;
  }
  log.lh.block[i] = b->blockno;
    800042c0:	0621                	addi	a2,a2,8
    800042c2:	060a                	slli	a2,a2,0x2
    800042c4:	0001d797          	auipc	a5,0x1d
    800042c8:	87c78793          	addi	a5,a5,-1924 # 80020b40 <log>
    800042cc:	963e                	add	a2,a2,a5
    800042ce:	44dc                	lw	a5,12(s1)
    800042d0:	ca1c                	sw	a5,16(a2)
  if (i == log.lh.n) {  // Add new block to log?
    bpin(b);
    800042d2:	8526                	mv	a0,s1
    800042d4:	fffff097          	auipc	ra,0xfffff
    800042d8:	da2080e7          	jalr	-606(ra) # 80003076 <bpin>
    log.lh.n++;
    800042dc:	0001d717          	auipc	a4,0x1d
    800042e0:	86470713          	addi	a4,a4,-1948 # 80020b40 <log>
    800042e4:	575c                	lw	a5,44(a4)
    800042e6:	2785                	addiw	a5,a5,1
    800042e8:	d75c                	sw	a5,44(a4)
    800042ea:	a835                	j	80004326 <log_write+0xca>
    panic("too big a transaction");
    800042ec:	00004517          	auipc	a0,0x4
    800042f0:	39450513          	addi	a0,a0,916 # 80008680 <syscalls+0x1f8>
    800042f4:	ffffc097          	auipc	ra,0xffffc
    800042f8:	24a080e7          	jalr	586(ra) # 8000053e <panic>
    panic("log_write outside of trans");
    800042fc:	00004517          	auipc	a0,0x4
    80004300:	39c50513          	addi	a0,a0,924 # 80008698 <syscalls+0x210>
    80004304:	ffffc097          	auipc	ra,0xffffc
    80004308:	23a080e7          	jalr	570(ra) # 8000053e <panic>
  log.lh.block[i] = b->blockno;
    8000430c:	00878713          	addi	a4,a5,8
    80004310:	00271693          	slli	a3,a4,0x2
    80004314:	0001d717          	auipc	a4,0x1d
    80004318:	82c70713          	addi	a4,a4,-2004 # 80020b40 <log>
    8000431c:	9736                	add	a4,a4,a3
    8000431e:	44d4                	lw	a3,12(s1)
    80004320:	cb14                	sw	a3,16(a4)
  if (i == log.lh.n) {  // Add new block to log?
    80004322:	faf608e3          	beq	a2,a5,800042d2 <log_write+0x76>
  }
  release(&log.lock);
    80004326:	0001d517          	auipc	a0,0x1d
    8000432a:	81a50513          	addi	a0,a0,-2022 # 80020b40 <log>
    8000432e:	ffffd097          	auipc	ra,0xffffd
    80004332:	9c0080e7          	jalr	-1600(ra) # 80000cee <release>
}
    80004336:	60e2                	ld	ra,24(sp)
    80004338:	6442                	ld	s0,16(sp)
    8000433a:	64a2                	ld	s1,8(sp)
    8000433c:	6902                	ld	s2,0(sp)
    8000433e:	6105                	addi	sp,sp,32
    80004340:	8082                	ret

0000000080004342 <initsleeplock>:
#include "proc.h"
#include "sleeplock.h"

void
initsleeplock(struct sleeplock *lk, char *name)
{
    80004342:	1101                	addi	sp,sp,-32
    80004344:	ec06                	sd	ra,24(sp)
    80004346:	e822                	sd	s0,16(sp)
    80004348:	e426                	sd	s1,8(sp)
    8000434a:	e04a                	sd	s2,0(sp)
    8000434c:	1000                	addi	s0,sp,32
    8000434e:	84aa                	mv	s1,a0
    80004350:	892e                	mv	s2,a1
  initlock(&lk->lk, "sleep lock");
    80004352:	00004597          	auipc	a1,0x4
    80004356:	36658593          	addi	a1,a1,870 # 800086b8 <syscalls+0x230>
    8000435a:	0521                	addi	a0,a0,8
    8000435c:	ffffd097          	auipc	ra,0xffffd
    80004360:	84e080e7          	jalr	-1970(ra) # 80000baa <initlock>
  lk->name = name;
    80004364:	0324b023          	sd	s2,32(s1)
  lk->locked = 0;
    80004368:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    8000436c:	0204a423          	sw	zero,40(s1)
}
    80004370:	60e2                	ld	ra,24(sp)
    80004372:	6442                	ld	s0,16(sp)
    80004374:	64a2                	ld	s1,8(sp)
    80004376:	6902                	ld	s2,0(sp)
    80004378:	6105                	addi	sp,sp,32
    8000437a:	8082                	ret

000000008000437c <acquiresleep>:

void
acquiresleep(struct sleeplock *lk)
{
    8000437c:	1101                	addi	sp,sp,-32
    8000437e:	ec06                	sd	ra,24(sp)
    80004380:	e822                	sd	s0,16(sp)
    80004382:	e426                	sd	s1,8(sp)
    80004384:	e04a                	sd	s2,0(sp)
    80004386:	1000                	addi	s0,sp,32
    80004388:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    8000438a:	00850913          	addi	s2,a0,8
    8000438e:	854a                	mv	a0,s2
    80004390:	ffffd097          	auipc	ra,0xffffd
    80004394:	8aa080e7          	jalr	-1878(ra) # 80000c3a <acquire>
  while (lk->locked) {
    80004398:	409c                	lw	a5,0(s1)
    8000439a:	cb89                	beqz	a5,800043ac <acquiresleep+0x30>
    sleep(lk, &lk->lk);
    8000439c:	85ca                	mv	a1,s2
    8000439e:	8526                	mv	a0,s1
    800043a0:	ffffe097          	auipc	ra,0xffffe
    800043a4:	d32080e7          	jalr	-718(ra) # 800020d2 <sleep>
  while (lk->locked) {
    800043a8:	409c                	lw	a5,0(s1)
    800043aa:	fbed                	bnez	a5,8000439c <acquiresleep+0x20>
  }
  lk->locked = 1;
    800043ac:	4785                	li	a5,1
    800043ae:	c09c                	sw	a5,0(s1)
  lk->pid = myproc()->pid;
    800043b0:	ffffd097          	auipc	ra,0xffffd
    800043b4:	67a080e7          	jalr	1658(ra) # 80001a2a <myproc>
    800043b8:	591c                	lw	a5,48(a0)
    800043ba:	d49c                	sw	a5,40(s1)
  release(&lk->lk);
    800043bc:	854a                	mv	a0,s2
    800043be:	ffffd097          	auipc	ra,0xffffd
    800043c2:	930080e7          	jalr	-1744(ra) # 80000cee <release>
}
    800043c6:	60e2                	ld	ra,24(sp)
    800043c8:	6442                	ld	s0,16(sp)
    800043ca:	64a2                	ld	s1,8(sp)
    800043cc:	6902                	ld	s2,0(sp)
    800043ce:	6105                	addi	sp,sp,32
    800043d0:	8082                	ret

00000000800043d2 <releasesleep>:

void
releasesleep(struct sleeplock *lk)
{
    800043d2:	1101                	addi	sp,sp,-32
    800043d4:	ec06                	sd	ra,24(sp)
    800043d6:	e822                	sd	s0,16(sp)
    800043d8:	e426                	sd	s1,8(sp)
    800043da:	e04a                	sd	s2,0(sp)
    800043dc:	1000                	addi	s0,sp,32
    800043de:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    800043e0:	00850913          	addi	s2,a0,8
    800043e4:	854a                	mv	a0,s2
    800043e6:	ffffd097          	auipc	ra,0xffffd
    800043ea:	854080e7          	jalr	-1964(ra) # 80000c3a <acquire>
  lk->locked = 0;
    800043ee:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    800043f2:	0204a423          	sw	zero,40(s1)
  wakeup(lk);
    800043f6:	8526                	mv	a0,s1
    800043f8:	ffffe097          	auipc	ra,0xffffe
    800043fc:	d3e080e7          	jalr	-706(ra) # 80002136 <wakeup>
  release(&lk->lk);
    80004400:	854a                	mv	a0,s2
    80004402:	ffffd097          	auipc	ra,0xffffd
    80004406:	8ec080e7          	jalr	-1812(ra) # 80000cee <release>
}
    8000440a:	60e2                	ld	ra,24(sp)
    8000440c:	6442                	ld	s0,16(sp)
    8000440e:	64a2                	ld	s1,8(sp)
    80004410:	6902                	ld	s2,0(sp)
    80004412:	6105                	addi	sp,sp,32
    80004414:	8082                	ret

0000000080004416 <holdingsleep>:

int
holdingsleep(struct sleeplock *lk)
{
    80004416:	7179                	addi	sp,sp,-48
    80004418:	f406                	sd	ra,40(sp)
    8000441a:	f022                	sd	s0,32(sp)
    8000441c:	ec26                	sd	s1,24(sp)
    8000441e:	e84a                	sd	s2,16(sp)
    80004420:	e44e                	sd	s3,8(sp)
    80004422:	1800                	addi	s0,sp,48
    80004424:	84aa                	mv	s1,a0
  int r;
  
  acquire(&lk->lk);
    80004426:	00850913          	addi	s2,a0,8
    8000442a:	854a                	mv	a0,s2
    8000442c:	ffffd097          	auipc	ra,0xffffd
    80004430:	80e080e7          	jalr	-2034(ra) # 80000c3a <acquire>
  r = lk->locked && (lk->pid == myproc()->pid);
    80004434:	409c                	lw	a5,0(s1)
    80004436:	ef99                	bnez	a5,80004454 <holdingsleep+0x3e>
    80004438:	4481                	li	s1,0
  release(&lk->lk);
    8000443a:	854a                	mv	a0,s2
    8000443c:	ffffd097          	auipc	ra,0xffffd
    80004440:	8b2080e7          	jalr	-1870(ra) # 80000cee <release>
  return r;
}
    80004444:	8526                	mv	a0,s1
    80004446:	70a2                	ld	ra,40(sp)
    80004448:	7402                	ld	s0,32(sp)
    8000444a:	64e2                	ld	s1,24(sp)
    8000444c:	6942                	ld	s2,16(sp)
    8000444e:	69a2                	ld	s3,8(sp)
    80004450:	6145                	addi	sp,sp,48
    80004452:	8082                	ret
  r = lk->locked && (lk->pid == myproc()->pid);
    80004454:	0284a983          	lw	s3,40(s1)
    80004458:	ffffd097          	auipc	ra,0xffffd
    8000445c:	5d2080e7          	jalr	1490(ra) # 80001a2a <myproc>
    80004460:	5904                	lw	s1,48(a0)
    80004462:	413484b3          	sub	s1,s1,s3
    80004466:	0014b493          	seqz	s1,s1
    8000446a:	bfc1                	j	8000443a <holdingsleep+0x24>

000000008000446c <fileinit>:
  struct file file[NFILE];
} ftable;

void
fileinit(void)
{
    8000446c:	1141                	addi	sp,sp,-16
    8000446e:	e406                	sd	ra,8(sp)
    80004470:	e022                	sd	s0,0(sp)
    80004472:	0800                	addi	s0,sp,16
  initlock(&ftable.lock, "ftable");
    80004474:	00004597          	auipc	a1,0x4
    80004478:	25458593          	addi	a1,a1,596 # 800086c8 <syscalls+0x240>
    8000447c:	0001d517          	auipc	a0,0x1d
    80004480:	80c50513          	addi	a0,a0,-2036 # 80020c88 <ftable>
    80004484:	ffffc097          	auipc	ra,0xffffc
    80004488:	726080e7          	jalr	1830(ra) # 80000baa <initlock>
}
    8000448c:	60a2                	ld	ra,8(sp)
    8000448e:	6402                	ld	s0,0(sp)
    80004490:	0141                	addi	sp,sp,16
    80004492:	8082                	ret

0000000080004494 <filealloc>:

// Allocate a file structure.
struct file*
filealloc(void)
{
    80004494:	1101                	addi	sp,sp,-32
    80004496:	ec06                	sd	ra,24(sp)
    80004498:	e822                	sd	s0,16(sp)
    8000449a:	e426                	sd	s1,8(sp)
    8000449c:	1000                	addi	s0,sp,32
  struct file *f;

  acquire(&ftable.lock);
    8000449e:	0001c517          	auipc	a0,0x1c
    800044a2:	7ea50513          	addi	a0,a0,2026 # 80020c88 <ftable>
    800044a6:	ffffc097          	auipc	ra,0xffffc
    800044aa:	794080e7          	jalr	1940(ra) # 80000c3a <acquire>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    800044ae:	0001c497          	auipc	s1,0x1c
    800044b2:	7f248493          	addi	s1,s1,2034 # 80020ca0 <ftable+0x18>
    800044b6:	0001d717          	auipc	a4,0x1d
    800044ba:	78a70713          	addi	a4,a4,1930 # 80021c40 <disk>
    if(f->ref == 0){
    800044be:	40dc                	lw	a5,4(s1)
    800044c0:	cf99                	beqz	a5,800044de <filealloc+0x4a>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    800044c2:	02848493          	addi	s1,s1,40
    800044c6:	fee49ce3          	bne	s1,a4,800044be <filealloc+0x2a>
      f->ref = 1;
      release(&ftable.lock);
      return f;
    }
  }
  release(&ftable.lock);
    800044ca:	0001c517          	auipc	a0,0x1c
    800044ce:	7be50513          	addi	a0,a0,1982 # 80020c88 <ftable>
    800044d2:	ffffd097          	auipc	ra,0xffffd
    800044d6:	81c080e7          	jalr	-2020(ra) # 80000cee <release>
  return 0;
    800044da:	4481                	li	s1,0
    800044dc:	a819                	j	800044f2 <filealloc+0x5e>
      f->ref = 1;
    800044de:	4785                	li	a5,1
    800044e0:	c0dc                	sw	a5,4(s1)
      release(&ftable.lock);
    800044e2:	0001c517          	auipc	a0,0x1c
    800044e6:	7a650513          	addi	a0,a0,1958 # 80020c88 <ftable>
    800044ea:	ffffd097          	auipc	ra,0xffffd
    800044ee:	804080e7          	jalr	-2044(ra) # 80000cee <release>
}
    800044f2:	8526                	mv	a0,s1
    800044f4:	60e2                	ld	ra,24(sp)
    800044f6:	6442                	ld	s0,16(sp)
    800044f8:	64a2                	ld	s1,8(sp)
    800044fa:	6105                	addi	sp,sp,32
    800044fc:	8082                	ret

00000000800044fe <filedup>:

// Increment ref count for file f.
struct file*
filedup(struct file *f)
{
    800044fe:	1101                	addi	sp,sp,-32
    80004500:	ec06                	sd	ra,24(sp)
    80004502:	e822                	sd	s0,16(sp)
    80004504:	e426                	sd	s1,8(sp)
    80004506:	1000                	addi	s0,sp,32
    80004508:	84aa                	mv	s1,a0
  acquire(&ftable.lock);
    8000450a:	0001c517          	auipc	a0,0x1c
    8000450e:	77e50513          	addi	a0,a0,1918 # 80020c88 <ftable>
    80004512:	ffffc097          	auipc	ra,0xffffc
    80004516:	728080e7          	jalr	1832(ra) # 80000c3a <acquire>
  if(f->ref < 1)
    8000451a:	40dc                	lw	a5,4(s1)
    8000451c:	02f05263          	blez	a5,80004540 <filedup+0x42>
    panic("filedup");
  f->ref++;
    80004520:	2785                	addiw	a5,a5,1
    80004522:	c0dc                	sw	a5,4(s1)
  release(&ftable.lock);
    80004524:	0001c517          	auipc	a0,0x1c
    80004528:	76450513          	addi	a0,a0,1892 # 80020c88 <ftable>
    8000452c:	ffffc097          	auipc	ra,0xffffc
    80004530:	7c2080e7          	jalr	1986(ra) # 80000cee <release>
  return f;
}
    80004534:	8526                	mv	a0,s1
    80004536:	60e2                	ld	ra,24(sp)
    80004538:	6442                	ld	s0,16(sp)
    8000453a:	64a2                	ld	s1,8(sp)
    8000453c:	6105                	addi	sp,sp,32
    8000453e:	8082                	ret
    panic("filedup");
    80004540:	00004517          	auipc	a0,0x4
    80004544:	19050513          	addi	a0,a0,400 # 800086d0 <syscalls+0x248>
    80004548:	ffffc097          	auipc	ra,0xffffc
    8000454c:	ff6080e7          	jalr	-10(ra) # 8000053e <panic>

0000000080004550 <fileclose>:

// Close file f.  (Decrement ref count, close when reaches 0.)
void
fileclose(struct file *f)
{
    80004550:	7139                	addi	sp,sp,-64
    80004552:	fc06                	sd	ra,56(sp)
    80004554:	f822                	sd	s0,48(sp)
    80004556:	f426                	sd	s1,40(sp)
    80004558:	f04a                	sd	s2,32(sp)
    8000455a:	ec4e                	sd	s3,24(sp)
    8000455c:	e852                	sd	s4,16(sp)
    8000455e:	e456                	sd	s5,8(sp)
    80004560:	0080                	addi	s0,sp,64
    80004562:	84aa                	mv	s1,a0
  struct file ff;

  acquire(&ftable.lock);
    80004564:	0001c517          	auipc	a0,0x1c
    80004568:	72450513          	addi	a0,a0,1828 # 80020c88 <ftable>
    8000456c:	ffffc097          	auipc	ra,0xffffc
    80004570:	6ce080e7          	jalr	1742(ra) # 80000c3a <acquire>
  if(f->ref < 1)
    80004574:	40dc                	lw	a5,4(s1)
    80004576:	06f05163          	blez	a5,800045d8 <fileclose+0x88>
    panic("fileclose");
  if(--f->ref > 0){
    8000457a:	37fd                	addiw	a5,a5,-1
    8000457c:	0007871b          	sext.w	a4,a5
    80004580:	c0dc                	sw	a5,4(s1)
    80004582:	06e04363          	bgtz	a4,800045e8 <fileclose+0x98>
    release(&ftable.lock);
    return;
  }
  ff = *f;
    80004586:	0004a903          	lw	s2,0(s1)
    8000458a:	0094ca83          	lbu	s5,9(s1)
    8000458e:	0104ba03          	ld	s4,16(s1)
    80004592:	0184b983          	ld	s3,24(s1)
  f->ref = 0;
    80004596:	0004a223          	sw	zero,4(s1)
  f->type = FD_NONE;
    8000459a:	0004a023          	sw	zero,0(s1)
  release(&ftable.lock);
    8000459e:	0001c517          	auipc	a0,0x1c
    800045a2:	6ea50513          	addi	a0,a0,1770 # 80020c88 <ftable>
    800045a6:	ffffc097          	auipc	ra,0xffffc
    800045aa:	748080e7          	jalr	1864(ra) # 80000cee <release>

  if(ff.type == FD_PIPE){
    800045ae:	4785                	li	a5,1
    800045b0:	04f90d63          	beq	s2,a5,8000460a <fileclose+0xba>
    pipeclose(ff.pipe, ff.writable);
  } else if(ff.type == FD_INODE || ff.type == FD_DEVICE){
    800045b4:	3979                	addiw	s2,s2,-2
    800045b6:	4785                	li	a5,1
    800045b8:	0527e063          	bltu	a5,s2,800045f8 <fileclose+0xa8>
    begin_op();
    800045bc:	00000097          	auipc	ra,0x0
    800045c0:	ac8080e7          	jalr	-1336(ra) # 80004084 <begin_op>
    iput(ff.ip);
    800045c4:	854e                	mv	a0,s3
    800045c6:	fffff097          	auipc	ra,0xfffff
    800045ca:	2b6080e7          	jalr	694(ra) # 8000387c <iput>
    end_op();
    800045ce:	00000097          	auipc	ra,0x0
    800045d2:	b36080e7          	jalr	-1226(ra) # 80004104 <end_op>
    800045d6:	a00d                	j	800045f8 <fileclose+0xa8>
    panic("fileclose");
    800045d8:	00004517          	auipc	a0,0x4
    800045dc:	10050513          	addi	a0,a0,256 # 800086d8 <syscalls+0x250>
    800045e0:	ffffc097          	auipc	ra,0xffffc
    800045e4:	f5e080e7          	jalr	-162(ra) # 8000053e <panic>
    release(&ftable.lock);
    800045e8:	0001c517          	auipc	a0,0x1c
    800045ec:	6a050513          	addi	a0,a0,1696 # 80020c88 <ftable>
    800045f0:	ffffc097          	auipc	ra,0xffffc
    800045f4:	6fe080e7          	jalr	1790(ra) # 80000cee <release>
  }
}
    800045f8:	70e2                	ld	ra,56(sp)
    800045fa:	7442                	ld	s0,48(sp)
    800045fc:	74a2                	ld	s1,40(sp)
    800045fe:	7902                	ld	s2,32(sp)
    80004600:	69e2                	ld	s3,24(sp)
    80004602:	6a42                	ld	s4,16(sp)
    80004604:	6aa2                	ld	s5,8(sp)
    80004606:	6121                	addi	sp,sp,64
    80004608:	8082                	ret
    pipeclose(ff.pipe, ff.writable);
    8000460a:	85d6                	mv	a1,s5
    8000460c:	8552                	mv	a0,s4
    8000460e:	00000097          	auipc	ra,0x0
    80004612:	34c080e7          	jalr	844(ra) # 8000495a <pipeclose>
    80004616:	b7cd                	j	800045f8 <fileclose+0xa8>

0000000080004618 <filestat>:

// Get metadata about file f.
// addr is a user virtual address, pointing to a struct stat.
int
filestat(struct file *f, uint64 addr)
{
    80004618:	715d                	addi	sp,sp,-80
    8000461a:	e486                	sd	ra,72(sp)
    8000461c:	e0a2                	sd	s0,64(sp)
    8000461e:	fc26                	sd	s1,56(sp)
    80004620:	f84a                	sd	s2,48(sp)
    80004622:	f44e                	sd	s3,40(sp)
    80004624:	0880                	addi	s0,sp,80
    80004626:	84aa                	mv	s1,a0
    80004628:	89ae                	mv	s3,a1
  struct proc *p = myproc();
    8000462a:	ffffd097          	auipc	ra,0xffffd
    8000462e:	400080e7          	jalr	1024(ra) # 80001a2a <myproc>
  struct stat st;
  
  if(f->type == FD_INODE || f->type == FD_DEVICE){
    80004632:	409c                	lw	a5,0(s1)
    80004634:	37f9                	addiw	a5,a5,-2
    80004636:	4705                	li	a4,1
    80004638:	04f76763          	bltu	a4,a5,80004686 <filestat+0x6e>
    8000463c:	892a                	mv	s2,a0
    ilock(f->ip);
    8000463e:	6c88                	ld	a0,24(s1)
    80004640:	fffff097          	auipc	ra,0xfffff
    80004644:	082080e7          	jalr	130(ra) # 800036c2 <ilock>
    stati(f->ip, &st);
    80004648:	fb840593          	addi	a1,s0,-72
    8000464c:	6c88                	ld	a0,24(s1)
    8000464e:	fffff097          	auipc	ra,0xfffff
    80004652:	2fe080e7          	jalr	766(ra) # 8000394c <stati>
    iunlock(f->ip);
    80004656:	6c88                	ld	a0,24(s1)
    80004658:	fffff097          	auipc	ra,0xfffff
    8000465c:	12c080e7          	jalr	300(ra) # 80003784 <iunlock>
    if(copyout(p->pagetable, addr, (char *)&st, sizeof(st)) < 0)
    80004660:	46e1                	li	a3,24
    80004662:	fb840613          	addi	a2,s0,-72
    80004666:	85ce                	mv	a1,s3
    80004668:	05093503          	ld	a0,80(s2)
    8000466c:	ffffd097          	auipc	ra,0xffffd
    80004670:	07a080e7          	jalr	122(ra) # 800016e6 <copyout>
    80004674:	41f5551b          	sraiw	a0,a0,0x1f
      return -1;
    return 0;
  }
  return -1;
}
    80004678:	60a6                	ld	ra,72(sp)
    8000467a:	6406                	ld	s0,64(sp)
    8000467c:	74e2                	ld	s1,56(sp)
    8000467e:	7942                	ld	s2,48(sp)
    80004680:	79a2                	ld	s3,40(sp)
    80004682:	6161                	addi	sp,sp,80
    80004684:	8082                	ret
  return -1;
    80004686:	557d                	li	a0,-1
    80004688:	bfc5                	j	80004678 <filestat+0x60>

000000008000468a <fileread>:

// Read from file f.
// addr is a user virtual address.
int
fileread(struct file *f, uint64 addr, int n)
{
    8000468a:	7179                	addi	sp,sp,-48
    8000468c:	f406                	sd	ra,40(sp)
    8000468e:	f022                	sd	s0,32(sp)
    80004690:	ec26                	sd	s1,24(sp)
    80004692:	e84a                	sd	s2,16(sp)
    80004694:	e44e                	sd	s3,8(sp)
    80004696:	1800                	addi	s0,sp,48
  int r = 0;

  if(f->readable == 0)
    80004698:	00854783          	lbu	a5,8(a0)
    8000469c:	c3d5                	beqz	a5,80004740 <fileread+0xb6>
    8000469e:	84aa                	mv	s1,a0
    800046a0:	89ae                	mv	s3,a1
    800046a2:	8932                	mv	s2,a2
    return -1;

  if(f->type == FD_PIPE){
    800046a4:	411c                	lw	a5,0(a0)
    800046a6:	4705                	li	a4,1
    800046a8:	04e78963          	beq	a5,a4,800046fa <fileread+0x70>
    r = piperead(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    800046ac:	470d                	li	a4,3
    800046ae:	04e78d63          	beq	a5,a4,80004708 <fileread+0x7e>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
      return -1;
    r = devsw[f->major].read(1, addr, n);
  } else if(f->type == FD_INODE){
    800046b2:	4709                	li	a4,2
    800046b4:	06e79e63          	bne	a5,a4,80004730 <fileread+0xa6>
    ilock(f->ip);
    800046b8:	6d08                	ld	a0,24(a0)
    800046ba:	fffff097          	auipc	ra,0xfffff
    800046be:	008080e7          	jalr	8(ra) # 800036c2 <ilock>
    if((r = readi(f->ip, 1, addr, f->off, n)) > 0)
    800046c2:	874a                	mv	a4,s2
    800046c4:	5094                	lw	a3,32(s1)
    800046c6:	864e                	mv	a2,s3
    800046c8:	4585                	li	a1,1
    800046ca:	6c88                	ld	a0,24(s1)
    800046cc:	fffff097          	auipc	ra,0xfffff
    800046d0:	2aa080e7          	jalr	682(ra) # 80003976 <readi>
    800046d4:	892a                	mv	s2,a0
    800046d6:	00a05563          	blez	a0,800046e0 <fileread+0x56>
      f->off += r;
    800046da:	509c                	lw	a5,32(s1)
    800046dc:	9fa9                	addw	a5,a5,a0
    800046de:	d09c                	sw	a5,32(s1)
    iunlock(f->ip);
    800046e0:	6c88                	ld	a0,24(s1)
    800046e2:	fffff097          	auipc	ra,0xfffff
    800046e6:	0a2080e7          	jalr	162(ra) # 80003784 <iunlock>
  } else {
    panic("fileread");
  }

  return r;
}
    800046ea:	854a                	mv	a0,s2
    800046ec:	70a2                	ld	ra,40(sp)
    800046ee:	7402                	ld	s0,32(sp)
    800046f0:	64e2                	ld	s1,24(sp)
    800046f2:	6942                	ld	s2,16(sp)
    800046f4:	69a2                	ld	s3,8(sp)
    800046f6:	6145                	addi	sp,sp,48
    800046f8:	8082                	ret
    r = piperead(f->pipe, addr, n);
    800046fa:	6908                	ld	a0,16(a0)
    800046fc:	00000097          	auipc	ra,0x0
    80004700:	3c6080e7          	jalr	966(ra) # 80004ac2 <piperead>
    80004704:	892a                	mv	s2,a0
    80004706:	b7d5                	j	800046ea <fileread+0x60>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
    80004708:	02451783          	lh	a5,36(a0)
    8000470c:	03079693          	slli	a3,a5,0x30
    80004710:	92c1                	srli	a3,a3,0x30
    80004712:	4725                	li	a4,9
    80004714:	02d76863          	bltu	a4,a3,80004744 <fileread+0xba>
    80004718:	0792                	slli	a5,a5,0x4
    8000471a:	0001c717          	auipc	a4,0x1c
    8000471e:	4ce70713          	addi	a4,a4,1230 # 80020be8 <devsw>
    80004722:	97ba                	add	a5,a5,a4
    80004724:	639c                	ld	a5,0(a5)
    80004726:	c38d                	beqz	a5,80004748 <fileread+0xbe>
    r = devsw[f->major].read(1, addr, n);
    80004728:	4505                	li	a0,1
    8000472a:	9782                	jalr	a5
    8000472c:	892a                	mv	s2,a0
    8000472e:	bf75                	j	800046ea <fileread+0x60>
    panic("fileread");
    80004730:	00004517          	auipc	a0,0x4
    80004734:	fb850513          	addi	a0,a0,-72 # 800086e8 <syscalls+0x260>
    80004738:	ffffc097          	auipc	ra,0xffffc
    8000473c:	e06080e7          	jalr	-506(ra) # 8000053e <panic>
    return -1;
    80004740:	597d                	li	s2,-1
    80004742:	b765                	j	800046ea <fileread+0x60>
      return -1;
    80004744:	597d                	li	s2,-1
    80004746:	b755                	j	800046ea <fileread+0x60>
    80004748:	597d                	li	s2,-1
    8000474a:	b745                	j	800046ea <fileread+0x60>

000000008000474c <filewrite>:

// Write to file f.
// addr is a user virtual address.
int
filewrite(struct file *f, uint64 addr, int n)
{
    8000474c:	715d                	addi	sp,sp,-80
    8000474e:	e486                	sd	ra,72(sp)
    80004750:	e0a2                	sd	s0,64(sp)
    80004752:	fc26                	sd	s1,56(sp)
    80004754:	f84a                	sd	s2,48(sp)
    80004756:	f44e                	sd	s3,40(sp)
    80004758:	f052                	sd	s4,32(sp)
    8000475a:	ec56                	sd	s5,24(sp)
    8000475c:	e85a                	sd	s6,16(sp)
    8000475e:	e45e                	sd	s7,8(sp)
    80004760:	e062                	sd	s8,0(sp)
    80004762:	0880                	addi	s0,sp,80
  int r, ret = 0;

  if(f->writable == 0)
    80004764:	00954783          	lbu	a5,9(a0)
    80004768:	10078663          	beqz	a5,80004874 <filewrite+0x128>
    8000476c:	892a                	mv	s2,a0
    8000476e:	8aae                	mv	s5,a1
    80004770:	8a32                	mv	s4,a2
    return -1;

  if(f->type == FD_PIPE){
    80004772:	411c                	lw	a5,0(a0)
    80004774:	4705                	li	a4,1
    80004776:	02e78263          	beq	a5,a4,8000479a <filewrite+0x4e>
    ret = pipewrite(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    8000477a:	470d                	li	a4,3
    8000477c:	02e78663          	beq	a5,a4,800047a8 <filewrite+0x5c>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
      return -1;
    ret = devsw[f->major].write(1, addr, n);
  } else if(f->type == FD_INODE){
    80004780:	4709                	li	a4,2
    80004782:	0ee79163          	bne	a5,a4,80004864 <filewrite+0x118>
    // and 2 blocks of slop for non-aligned writes.
    // this really belongs lower down, since writei()
    // might be writing a device like the console.
    int max = ((MAXOPBLOCKS-1-1-2) / 2) * BSIZE;
    int i = 0;
    while(i < n){
    80004786:	0ac05d63          	blez	a2,80004840 <filewrite+0xf4>
    int i = 0;
    8000478a:	4981                	li	s3,0
    8000478c:	6b05                	lui	s6,0x1
    8000478e:	c00b0b13          	addi	s6,s6,-1024 # c00 <_entry-0x7ffff400>
    80004792:	6b85                	lui	s7,0x1
    80004794:	c00b8b9b          	addiw	s7,s7,-1024
    80004798:	a861                	j	80004830 <filewrite+0xe4>
    ret = pipewrite(f->pipe, addr, n);
    8000479a:	6908                	ld	a0,16(a0)
    8000479c:	00000097          	auipc	ra,0x0
    800047a0:	22e080e7          	jalr	558(ra) # 800049ca <pipewrite>
    800047a4:	8a2a                	mv	s4,a0
    800047a6:	a045                	j	80004846 <filewrite+0xfa>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
    800047a8:	02451783          	lh	a5,36(a0)
    800047ac:	03079693          	slli	a3,a5,0x30
    800047b0:	92c1                	srli	a3,a3,0x30
    800047b2:	4725                	li	a4,9
    800047b4:	0cd76263          	bltu	a4,a3,80004878 <filewrite+0x12c>
    800047b8:	0792                	slli	a5,a5,0x4
    800047ba:	0001c717          	auipc	a4,0x1c
    800047be:	42e70713          	addi	a4,a4,1070 # 80020be8 <devsw>
    800047c2:	97ba                	add	a5,a5,a4
    800047c4:	679c                	ld	a5,8(a5)
    800047c6:	cbdd                	beqz	a5,8000487c <filewrite+0x130>
    ret = devsw[f->major].write(1, addr, n);
    800047c8:	4505                	li	a0,1
    800047ca:	9782                	jalr	a5
    800047cc:	8a2a                	mv	s4,a0
    800047ce:	a8a5                	j	80004846 <filewrite+0xfa>
    800047d0:	00048c1b          	sext.w	s8,s1
      int n1 = n - i;
      if(n1 > max)
        n1 = max;

      begin_op();
    800047d4:	00000097          	auipc	ra,0x0
    800047d8:	8b0080e7          	jalr	-1872(ra) # 80004084 <begin_op>
      ilock(f->ip);
    800047dc:	01893503          	ld	a0,24(s2)
    800047e0:	fffff097          	auipc	ra,0xfffff
    800047e4:	ee2080e7          	jalr	-286(ra) # 800036c2 <ilock>
      if ((r = writei(f->ip, 1, addr + i, f->off, n1)) > 0)
    800047e8:	8762                	mv	a4,s8
    800047ea:	02092683          	lw	a3,32(s2)
    800047ee:	01598633          	add	a2,s3,s5
    800047f2:	4585                	li	a1,1
    800047f4:	01893503          	ld	a0,24(s2)
    800047f8:	fffff097          	auipc	ra,0xfffff
    800047fc:	276080e7          	jalr	630(ra) # 80003a6e <writei>
    80004800:	84aa                	mv	s1,a0
    80004802:	00a05763          	blez	a0,80004810 <filewrite+0xc4>
        f->off += r;
    80004806:	02092783          	lw	a5,32(s2)
    8000480a:	9fa9                	addw	a5,a5,a0
    8000480c:	02f92023          	sw	a5,32(s2)
      iunlock(f->ip);
    80004810:	01893503          	ld	a0,24(s2)
    80004814:	fffff097          	auipc	ra,0xfffff
    80004818:	f70080e7          	jalr	-144(ra) # 80003784 <iunlock>
      end_op();
    8000481c:	00000097          	auipc	ra,0x0
    80004820:	8e8080e7          	jalr	-1816(ra) # 80004104 <end_op>

      if(r != n1){
    80004824:	009c1f63          	bne	s8,s1,80004842 <filewrite+0xf6>
        // error from writei
        break;
      }
      i += r;
    80004828:	013489bb          	addw	s3,s1,s3
    while(i < n){
    8000482c:	0149db63          	bge	s3,s4,80004842 <filewrite+0xf6>
      int n1 = n - i;
    80004830:	413a07bb          	subw	a5,s4,s3
      if(n1 > max)
    80004834:	84be                	mv	s1,a5
    80004836:	2781                	sext.w	a5,a5
    80004838:	f8fb5ce3          	bge	s6,a5,800047d0 <filewrite+0x84>
    8000483c:	84de                	mv	s1,s7
    8000483e:	bf49                	j	800047d0 <filewrite+0x84>
    int i = 0;
    80004840:	4981                	li	s3,0
    }
    ret = (i == n ? n : -1);
    80004842:	013a1f63          	bne	s4,s3,80004860 <filewrite+0x114>
  } else {
    panic("filewrite");
  }

  return ret;
}
    80004846:	8552                	mv	a0,s4
    80004848:	60a6                	ld	ra,72(sp)
    8000484a:	6406                	ld	s0,64(sp)
    8000484c:	74e2                	ld	s1,56(sp)
    8000484e:	7942                	ld	s2,48(sp)
    80004850:	79a2                	ld	s3,40(sp)
    80004852:	7a02                	ld	s4,32(sp)
    80004854:	6ae2                	ld	s5,24(sp)
    80004856:	6b42                	ld	s6,16(sp)
    80004858:	6ba2                	ld	s7,8(sp)
    8000485a:	6c02                	ld	s8,0(sp)
    8000485c:	6161                	addi	sp,sp,80
    8000485e:	8082                	ret
    ret = (i == n ? n : -1);
    80004860:	5a7d                	li	s4,-1
    80004862:	b7d5                	j	80004846 <filewrite+0xfa>
    panic("filewrite");
    80004864:	00004517          	auipc	a0,0x4
    80004868:	e9450513          	addi	a0,a0,-364 # 800086f8 <syscalls+0x270>
    8000486c:	ffffc097          	auipc	ra,0xffffc
    80004870:	cd2080e7          	jalr	-814(ra) # 8000053e <panic>
    return -1;
    80004874:	5a7d                	li	s4,-1
    80004876:	bfc1                	j	80004846 <filewrite+0xfa>
      return -1;
    80004878:	5a7d                	li	s4,-1
    8000487a:	b7f1                	j	80004846 <filewrite+0xfa>
    8000487c:	5a7d                	li	s4,-1
    8000487e:	b7e1                	j	80004846 <filewrite+0xfa>

0000000080004880 <pipealloc>:
  int writeopen;  // write fd is still open
};

int
pipealloc(struct file **f0, struct file **f1)
{
    80004880:	7179                	addi	sp,sp,-48
    80004882:	f406                	sd	ra,40(sp)
    80004884:	f022                	sd	s0,32(sp)
    80004886:	ec26                	sd	s1,24(sp)
    80004888:	e84a                	sd	s2,16(sp)
    8000488a:	e44e                	sd	s3,8(sp)
    8000488c:	e052                	sd	s4,0(sp)
    8000488e:	1800                	addi	s0,sp,48
    80004890:	84aa                	mv	s1,a0
    80004892:	8a2e                	mv	s4,a1
  struct pipe *pi;

  pi = 0;
  *f0 = *f1 = 0;
    80004894:	0005b023          	sd	zero,0(a1)
    80004898:	00053023          	sd	zero,0(a0)
  if((*f0 = filealloc()) == 0 || (*f1 = filealloc()) == 0)
    8000489c:	00000097          	auipc	ra,0x0
    800048a0:	bf8080e7          	jalr	-1032(ra) # 80004494 <filealloc>
    800048a4:	e088                	sd	a0,0(s1)
    800048a6:	c551                	beqz	a0,80004932 <pipealloc+0xb2>
    800048a8:	00000097          	auipc	ra,0x0
    800048ac:	bec080e7          	jalr	-1044(ra) # 80004494 <filealloc>
    800048b0:	00aa3023          	sd	a0,0(s4)
    800048b4:	c92d                	beqz	a0,80004926 <pipealloc+0xa6>
    goto bad;
  if((pi = (struct pipe*)kalloc()) == 0)
    800048b6:	ffffc097          	auipc	ra,0xffffc
    800048ba:	230080e7          	jalr	560(ra) # 80000ae6 <kalloc>
    800048be:	892a                	mv	s2,a0
    800048c0:	c125                	beqz	a0,80004920 <pipealloc+0xa0>
    goto bad;
  pi->readopen = 1;
    800048c2:	4985                	li	s3,1
    800048c4:	23352023          	sw	s3,544(a0)
  pi->writeopen = 1;
    800048c8:	23352223          	sw	s3,548(a0)
  pi->nwrite = 0;
    800048cc:	20052e23          	sw	zero,540(a0)
  pi->nread = 0;
    800048d0:	20052c23          	sw	zero,536(a0)
  initlock(&pi->lock, "pipe");
    800048d4:	00004597          	auipc	a1,0x4
    800048d8:	e3458593          	addi	a1,a1,-460 # 80008708 <syscalls+0x280>
    800048dc:	ffffc097          	auipc	ra,0xffffc
    800048e0:	2ce080e7          	jalr	718(ra) # 80000baa <initlock>
  (*f0)->type = FD_PIPE;
    800048e4:	609c                	ld	a5,0(s1)
    800048e6:	0137a023          	sw	s3,0(a5)
  (*f0)->readable = 1;
    800048ea:	609c                	ld	a5,0(s1)
    800048ec:	01378423          	sb	s3,8(a5)
  (*f0)->writable = 0;
    800048f0:	609c                	ld	a5,0(s1)
    800048f2:	000784a3          	sb	zero,9(a5)
  (*f0)->pipe = pi;
    800048f6:	609c                	ld	a5,0(s1)
    800048f8:	0127b823          	sd	s2,16(a5)
  (*f1)->type = FD_PIPE;
    800048fc:	000a3783          	ld	a5,0(s4)
    80004900:	0137a023          	sw	s3,0(a5)
  (*f1)->readable = 0;
    80004904:	000a3783          	ld	a5,0(s4)
    80004908:	00078423          	sb	zero,8(a5)
  (*f1)->writable = 1;
    8000490c:	000a3783          	ld	a5,0(s4)
    80004910:	013784a3          	sb	s3,9(a5)
  (*f1)->pipe = pi;
    80004914:	000a3783          	ld	a5,0(s4)
    80004918:	0127b823          	sd	s2,16(a5)
  return 0;
    8000491c:	4501                	li	a0,0
    8000491e:	a025                	j	80004946 <pipealloc+0xc6>

 bad:
  if(pi)
    kfree((char*)pi);
  if(*f0)
    80004920:	6088                	ld	a0,0(s1)
    80004922:	e501                	bnez	a0,8000492a <pipealloc+0xaa>
    80004924:	a039                	j	80004932 <pipealloc+0xb2>
    80004926:	6088                	ld	a0,0(s1)
    80004928:	c51d                	beqz	a0,80004956 <pipealloc+0xd6>
    fileclose(*f0);
    8000492a:	00000097          	auipc	ra,0x0
    8000492e:	c26080e7          	jalr	-986(ra) # 80004550 <fileclose>
  if(*f1)
    80004932:	000a3783          	ld	a5,0(s4)
    fileclose(*f1);
  return -1;
    80004936:	557d                	li	a0,-1
  if(*f1)
    80004938:	c799                	beqz	a5,80004946 <pipealloc+0xc6>
    fileclose(*f1);
    8000493a:	853e                	mv	a0,a5
    8000493c:	00000097          	auipc	ra,0x0
    80004940:	c14080e7          	jalr	-1004(ra) # 80004550 <fileclose>
  return -1;
    80004944:	557d                	li	a0,-1
}
    80004946:	70a2                	ld	ra,40(sp)
    80004948:	7402                	ld	s0,32(sp)
    8000494a:	64e2                	ld	s1,24(sp)
    8000494c:	6942                	ld	s2,16(sp)
    8000494e:	69a2                	ld	s3,8(sp)
    80004950:	6a02                	ld	s4,0(sp)
    80004952:	6145                	addi	sp,sp,48
    80004954:	8082                	ret
  return -1;
    80004956:	557d                	li	a0,-1
    80004958:	b7fd                	j	80004946 <pipealloc+0xc6>

000000008000495a <pipeclose>:

void
pipeclose(struct pipe *pi, int writable)
{
    8000495a:	1101                	addi	sp,sp,-32
    8000495c:	ec06                	sd	ra,24(sp)
    8000495e:	e822                	sd	s0,16(sp)
    80004960:	e426                	sd	s1,8(sp)
    80004962:	e04a                	sd	s2,0(sp)
    80004964:	1000                	addi	s0,sp,32
    80004966:	84aa                	mv	s1,a0
    80004968:	892e                	mv	s2,a1
  acquire(&pi->lock);
    8000496a:	ffffc097          	auipc	ra,0xffffc
    8000496e:	2d0080e7          	jalr	720(ra) # 80000c3a <acquire>
  if(writable){
    80004972:	02090d63          	beqz	s2,800049ac <pipeclose+0x52>
    pi->writeopen = 0;
    80004976:	2204a223          	sw	zero,548(s1)
    wakeup(&pi->nread);
    8000497a:	21848513          	addi	a0,s1,536
    8000497e:	ffffd097          	auipc	ra,0xffffd
    80004982:	7b8080e7          	jalr	1976(ra) # 80002136 <wakeup>
  } else {
    pi->readopen = 0;
    wakeup(&pi->nwrite);
  }
  if(pi->readopen == 0 && pi->writeopen == 0){
    80004986:	2204b783          	ld	a5,544(s1)
    8000498a:	eb95                	bnez	a5,800049be <pipeclose+0x64>
    release(&pi->lock);
    8000498c:	8526                	mv	a0,s1
    8000498e:	ffffc097          	auipc	ra,0xffffc
    80004992:	360080e7          	jalr	864(ra) # 80000cee <release>
    kfree((char*)pi);
    80004996:	8526                	mv	a0,s1
    80004998:	ffffc097          	auipc	ra,0xffffc
    8000499c:	052080e7          	jalr	82(ra) # 800009ea <kfree>
  } else
    release(&pi->lock);
}
    800049a0:	60e2                	ld	ra,24(sp)
    800049a2:	6442                	ld	s0,16(sp)
    800049a4:	64a2                	ld	s1,8(sp)
    800049a6:	6902                	ld	s2,0(sp)
    800049a8:	6105                	addi	sp,sp,32
    800049aa:	8082                	ret
    pi->readopen = 0;
    800049ac:	2204a023          	sw	zero,544(s1)
    wakeup(&pi->nwrite);
    800049b0:	21c48513          	addi	a0,s1,540
    800049b4:	ffffd097          	auipc	ra,0xffffd
    800049b8:	782080e7          	jalr	1922(ra) # 80002136 <wakeup>
    800049bc:	b7e9                	j	80004986 <pipeclose+0x2c>
    release(&pi->lock);
    800049be:	8526                	mv	a0,s1
    800049c0:	ffffc097          	auipc	ra,0xffffc
    800049c4:	32e080e7          	jalr	814(ra) # 80000cee <release>
}
    800049c8:	bfe1                	j	800049a0 <pipeclose+0x46>

00000000800049ca <pipewrite>:

int
pipewrite(struct pipe *pi, uint64 addr, int n)
{
    800049ca:	711d                	addi	sp,sp,-96
    800049cc:	ec86                	sd	ra,88(sp)
    800049ce:	e8a2                	sd	s0,80(sp)
    800049d0:	e4a6                	sd	s1,72(sp)
    800049d2:	e0ca                	sd	s2,64(sp)
    800049d4:	fc4e                	sd	s3,56(sp)
    800049d6:	f852                	sd	s4,48(sp)
    800049d8:	f456                	sd	s5,40(sp)
    800049da:	f05a                	sd	s6,32(sp)
    800049dc:	ec5e                	sd	s7,24(sp)
    800049de:	e862                	sd	s8,16(sp)
    800049e0:	1080                	addi	s0,sp,96
    800049e2:	84aa                	mv	s1,a0
    800049e4:	8aae                	mv	s5,a1
    800049e6:	8a32                	mv	s4,a2
  int i = 0;
  struct proc *pr = myproc();
    800049e8:	ffffd097          	auipc	ra,0xffffd
    800049ec:	042080e7          	jalr	66(ra) # 80001a2a <myproc>
    800049f0:	89aa                	mv	s3,a0

  acquire(&pi->lock);
    800049f2:	8526                	mv	a0,s1
    800049f4:	ffffc097          	auipc	ra,0xffffc
    800049f8:	246080e7          	jalr	582(ra) # 80000c3a <acquire>
  while(i < n){
    800049fc:	0b405663          	blez	s4,80004aa8 <pipewrite+0xde>
  int i = 0;
    80004a00:	4901                	li	s2,0
    if(pi->nwrite == pi->nread + PIPESIZE){ //DOC: pipewrite-full
      wakeup(&pi->nread);
      sleep(&pi->nwrite, &pi->lock);
    } else {
      char ch;
      if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    80004a02:	5b7d                	li	s6,-1
      wakeup(&pi->nread);
    80004a04:	21848c13          	addi	s8,s1,536
      sleep(&pi->nwrite, &pi->lock);
    80004a08:	21c48b93          	addi	s7,s1,540
    80004a0c:	a089                	j	80004a4e <pipewrite+0x84>
      release(&pi->lock);
    80004a0e:	8526                	mv	a0,s1
    80004a10:	ffffc097          	auipc	ra,0xffffc
    80004a14:	2de080e7          	jalr	734(ra) # 80000cee <release>
      return -1;
    80004a18:	597d                	li	s2,-1
  }
  wakeup(&pi->nread);
  release(&pi->lock);

  return i;
}
    80004a1a:	854a                	mv	a0,s2
    80004a1c:	60e6                	ld	ra,88(sp)
    80004a1e:	6446                	ld	s0,80(sp)
    80004a20:	64a6                	ld	s1,72(sp)
    80004a22:	6906                	ld	s2,64(sp)
    80004a24:	79e2                	ld	s3,56(sp)
    80004a26:	7a42                	ld	s4,48(sp)
    80004a28:	7aa2                	ld	s5,40(sp)
    80004a2a:	7b02                	ld	s6,32(sp)
    80004a2c:	6be2                	ld	s7,24(sp)
    80004a2e:	6c42                	ld	s8,16(sp)
    80004a30:	6125                	addi	sp,sp,96
    80004a32:	8082                	ret
      wakeup(&pi->nread);
    80004a34:	8562                	mv	a0,s8
    80004a36:	ffffd097          	auipc	ra,0xffffd
    80004a3a:	700080e7          	jalr	1792(ra) # 80002136 <wakeup>
      sleep(&pi->nwrite, &pi->lock);
    80004a3e:	85a6                	mv	a1,s1
    80004a40:	855e                	mv	a0,s7
    80004a42:	ffffd097          	auipc	ra,0xffffd
    80004a46:	690080e7          	jalr	1680(ra) # 800020d2 <sleep>
  while(i < n){
    80004a4a:	07495063          	bge	s2,s4,80004aaa <pipewrite+0xe0>
    if(pi->readopen == 0 || killed(pr)){
    80004a4e:	2204a783          	lw	a5,544(s1)
    80004a52:	dfd5                	beqz	a5,80004a0e <pipewrite+0x44>
    80004a54:	854e                	mv	a0,s3
    80004a56:	ffffe097          	auipc	ra,0xffffe
    80004a5a:	924080e7          	jalr	-1756(ra) # 8000237a <killed>
    80004a5e:	f945                	bnez	a0,80004a0e <pipewrite+0x44>
    if(pi->nwrite == pi->nread + PIPESIZE){ //DOC: pipewrite-full
    80004a60:	2184a783          	lw	a5,536(s1)
    80004a64:	21c4a703          	lw	a4,540(s1)
    80004a68:	2007879b          	addiw	a5,a5,512
    80004a6c:	fcf704e3          	beq	a4,a5,80004a34 <pipewrite+0x6a>
      if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    80004a70:	4685                	li	a3,1
    80004a72:	01590633          	add	a2,s2,s5
    80004a76:	faf40593          	addi	a1,s0,-81
    80004a7a:	0509b503          	ld	a0,80(s3)
    80004a7e:	ffffd097          	auipc	ra,0xffffd
    80004a82:	cf4080e7          	jalr	-780(ra) # 80001772 <copyin>
    80004a86:	03650263          	beq	a0,s6,80004aaa <pipewrite+0xe0>
      pi->data[pi->nwrite++ % PIPESIZE] = ch;
    80004a8a:	21c4a783          	lw	a5,540(s1)
    80004a8e:	0017871b          	addiw	a4,a5,1
    80004a92:	20e4ae23          	sw	a4,540(s1)
    80004a96:	1ff7f793          	andi	a5,a5,511
    80004a9a:	97a6                	add	a5,a5,s1
    80004a9c:	faf44703          	lbu	a4,-81(s0)
    80004aa0:	00e78c23          	sb	a4,24(a5)
      i++;
    80004aa4:	2905                	addiw	s2,s2,1
    80004aa6:	b755                	j	80004a4a <pipewrite+0x80>
  int i = 0;
    80004aa8:	4901                	li	s2,0
  wakeup(&pi->nread);
    80004aaa:	21848513          	addi	a0,s1,536
    80004aae:	ffffd097          	auipc	ra,0xffffd
    80004ab2:	688080e7          	jalr	1672(ra) # 80002136 <wakeup>
  release(&pi->lock);
    80004ab6:	8526                	mv	a0,s1
    80004ab8:	ffffc097          	auipc	ra,0xffffc
    80004abc:	236080e7          	jalr	566(ra) # 80000cee <release>
  return i;
    80004ac0:	bfa9                	j	80004a1a <pipewrite+0x50>

0000000080004ac2 <piperead>:

int
piperead(struct pipe *pi, uint64 addr, int n)
{
    80004ac2:	715d                	addi	sp,sp,-80
    80004ac4:	e486                	sd	ra,72(sp)
    80004ac6:	e0a2                	sd	s0,64(sp)
    80004ac8:	fc26                	sd	s1,56(sp)
    80004aca:	f84a                	sd	s2,48(sp)
    80004acc:	f44e                	sd	s3,40(sp)
    80004ace:	f052                	sd	s4,32(sp)
    80004ad0:	ec56                	sd	s5,24(sp)
    80004ad2:	e85a                	sd	s6,16(sp)
    80004ad4:	0880                	addi	s0,sp,80
    80004ad6:	84aa                	mv	s1,a0
    80004ad8:	892e                	mv	s2,a1
    80004ada:	8ab2                	mv	s5,a2
  int i;
  struct proc *pr = myproc();
    80004adc:	ffffd097          	auipc	ra,0xffffd
    80004ae0:	f4e080e7          	jalr	-178(ra) # 80001a2a <myproc>
    80004ae4:	8a2a                	mv	s4,a0
  char ch;

  acquire(&pi->lock);
    80004ae6:	8526                	mv	a0,s1
    80004ae8:	ffffc097          	auipc	ra,0xffffc
    80004aec:	152080e7          	jalr	338(ra) # 80000c3a <acquire>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80004af0:	2184a703          	lw	a4,536(s1)
    80004af4:	21c4a783          	lw	a5,540(s1)
    if(killed(pr)){
      release(&pi->lock);
      return -1;
    }
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    80004af8:	21848993          	addi	s3,s1,536
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80004afc:	02f71763          	bne	a4,a5,80004b2a <piperead+0x68>
    80004b00:	2244a783          	lw	a5,548(s1)
    80004b04:	c39d                	beqz	a5,80004b2a <piperead+0x68>
    if(killed(pr)){
    80004b06:	8552                	mv	a0,s4
    80004b08:	ffffe097          	auipc	ra,0xffffe
    80004b0c:	872080e7          	jalr	-1934(ra) # 8000237a <killed>
    80004b10:	e941                	bnez	a0,80004ba0 <piperead+0xde>
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    80004b12:	85a6                	mv	a1,s1
    80004b14:	854e                	mv	a0,s3
    80004b16:	ffffd097          	auipc	ra,0xffffd
    80004b1a:	5bc080e7          	jalr	1468(ra) # 800020d2 <sleep>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80004b1e:	2184a703          	lw	a4,536(s1)
    80004b22:	21c4a783          	lw	a5,540(s1)
    80004b26:	fcf70de3          	beq	a4,a5,80004b00 <piperead+0x3e>
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80004b2a:	4981                	li	s3,0
    if(pi->nread == pi->nwrite)
      break;
    ch = pi->data[pi->nread++ % PIPESIZE];
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1)
    80004b2c:	5b7d                	li	s6,-1
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80004b2e:	05505363          	blez	s5,80004b74 <piperead+0xb2>
    if(pi->nread == pi->nwrite)
    80004b32:	2184a783          	lw	a5,536(s1)
    80004b36:	21c4a703          	lw	a4,540(s1)
    80004b3a:	02f70d63          	beq	a4,a5,80004b74 <piperead+0xb2>
    ch = pi->data[pi->nread++ % PIPESIZE];
    80004b3e:	0017871b          	addiw	a4,a5,1
    80004b42:	20e4ac23          	sw	a4,536(s1)
    80004b46:	1ff7f793          	andi	a5,a5,511
    80004b4a:	97a6                	add	a5,a5,s1
    80004b4c:	0187c783          	lbu	a5,24(a5)
    80004b50:	faf40fa3          	sb	a5,-65(s0)
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1)
    80004b54:	4685                	li	a3,1
    80004b56:	fbf40613          	addi	a2,s0,-65
    80004b5a:	85ca                	mv	a1,s2
    80004b5c:	050a3503          	ld	a0,80(s4)
    80004b60:	ffffd097          	auipc	ra,0xffffd
    80004b64:	b86080e7          	jalr	-1146(ra) # 800016e6 <copyout>
    80004b68:	01650663          	beq	a0,s6,80004b74 <piperead+0xb2>
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80004b6c:	2985                	addiw	s3,s3,1
    80004b6e:	0905                	addi	s2,s2,1
    80004b70:	fd3a91e3          	bne	s5,s3,80004b32 <piperead+0x70>
      break;
  }
  wakeup(&pi->nwrite);  //DOC: piperead-wakeup
    80004b74:	21c48513          	addi	a0,s1,540
    80004b78:	ffffd097          	auipc	ra,0xffffd
    80004b7c:	5be080e7          	jalr	1470(ra) # 80002136 <wakeup>
  release(&pi->lock);
    80004b80:	8526                	mv	a0,s1
    80004b82:	ffffc097          	auipc	ra,0xffffc
    80004b86:	16c080e7          	jalr	364(ra) # 80000cee <release>
  return i;
}
    80004b8a:	854e                	mv	a0,s3
    80004b8c:	60a6                	ld	ra,72(sp)
    80004b8e:	6406                	ld	s0,64(sp)
    80004b90:	74e2                	ld	s1,56(sp)
    80004b92:	7942                	ld	s2,48(sp)
    80004b94:	79a2                	ld	s3,40(sp)
    80004b96:	7a02                	ld	s4,32(sp)
    80004b98:	6ae2                	ld	s5,24(sp)
    80004b9a:	6b42                	ld	s6,16(sp)
    80004b9c:	6161                	addi	sp,sp,80
    80004b9e:	8082                	ret
      release(&pi->lock);
    80004ba0:	8526                	mv	a0,s1
    80004ba2:	ffffc097          	auipc	ra,0xffffc
    80004ba6:	14c080e7          	jalr	332(ra) # 80000cee <release>
      return -1;
    80004baa:	59fd                	li	s3,-1
    80004bac:	bff9                	j	80004b8a <piperead+0xc8>

0000000080004bae <flags2perm>:
#include "elf.h"

static int loadseg(pde_t *, uint64, struct inode *, uint, uint);

int flags2perm(int flags)
{
    80004bae:	1141                	addi	sp,sp,-16
    80004bb0:	e422                	sd	s0,8(sp)
    80004bb2:	0800                	addi	s0,sp,16
    80004bb4:	87aa                	mv	a5,a0
    int perm = 0;
    if(flags & 0x1)
    80004bb6:	8905                	andi	a0,a0,1
    80004bb8:	c111                	beqz	a0,80004bbc <flags2perm+0xe>
      perm = PTE_X;
    80004bba:	4521                	li	a0,8
    if(flags & 0x2)
    80004bbc:	8b89                	andi	a5,a5,2
    80004bbe:	c399                	beqz	a5,80004bc4 <flags2perm+0x16>
      perm |= PTE_W;
    80004bc0:	00456513          	ori	a0,a0,4
    return perm;
}
    80004bc4:	6422                	ld	s0,8(sp)
    80004bc6:	0141                	addi	sp,sp,16
    80004bc8:	8082                	ret

0000000080004bca <exec>:

int
exec(char *path, char **argv)
{
    80004bca:	de010113          	addi	sp,sp,-544
    80004bce:	20113c23          	sd	ra,536(sp)
    80004bd2:	20813823          	sd	s0,528(sp)
    80004bd6:	20913423          	sd	s1,520(sp)
    80004bda:	21213023          	sd	s2,512(sp)
    80004bde:	ffce                	sd	s3,504(sp)
    80004be0:	fbd2                	sd	s4,496(sp)
    80004be2:	f7d6                	sd	s5,488(sp)
    80004be4:	f3da                	sd	s6,480(sp)
    80004be6:	efde                	sd	s7,472(sp)
    80004be8:	ebe2                	sd	s8,464(sp)
    80004bea:	e7e6                	sd	s9,456(sp)
    80004bec:	e3ea                	sd	s10,448(sp)
    80004bee:	ff6e                	sd	s11,440(sp)
    80004bf0:	1400                	addi	s0,sp,544
    80004bf2:	892a                	mv	s2,a0
    80004bf4:	dea43423          	sd	a0,-536(s0)
    80004bf8:	deb43823          	sd	a1,-528(s0)
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
  struct elfhdr elf;
  struct inode *ip;
  struct proghdr ph;
  pagetable_t pagetable = 0, oldpagetable;
  struct proc *p = myproc();
    80004bfc:	ffffd097          	auipc	ra,0xffffd
    80004c00:	e2e080e7          	jalr	-466(ra) # 80001a2a <myproc>
    80004c04:	84aa                	mv	s1,a0

  begin_op();
    80004c06:	fffff097          	auipc	ra,0xfffff
    80004c0a:	47e080e7          	jalr	1150(ra) # 80004084 <begin_op>

  if((ip = namei(path)) == 0){
    80004c0e:	854a                	mv	a0,s2
    80004c10:	fffff097          	auipc	ra,0xfffff
    80004c14:	258080e7          	jalr	600(ra) # 80003e68 <namei>
    80004c18:	c93d                	beqz	a0,80004c8e <exec+0xc4>
    80004c1a:	8aaa                	mv	s5,a0
    end_op();
    return -1;
  }
  ilock(ip);
    80004c1c:	fffff097          	auipc	ra,0xfffff
    80004c20:	aa6080e7          	jalr	-1370(ra) # 800036c2 <ilock>

  // Check ELF header
  if(readi(ip, 0, (uint64)&elf, 0, sizeof(elf)) != sizeof(elf))
    80004c24:	04000713          	li	a4,64
    80004c28:	4681                	li	a3,0
    80004c2a:	e5040613          	addi	a2,s0,-432
    80004c2e:	4581                	li	a1,0
    80004c30:	8556                	mv	a0,s5
    80004c32:	fffff097          	auipc	ra,0xfffff
    80004c36:	d44080e7          	jalr	-700(ra) # 80003976 <readi>
    80004c3a:	04000793          	li	a5,64
    80004c3e:	00f51a63          	bne	a0,a5,80004c52 <exec+0x88>
    goto bad;

  if(elf.magic != ELF_MAGIC)
    80004c42:	e5042703          	lw	a4,-432(s0)
    80004c46:	464c47b7          	lui	a5,0x464c4
    80004c4a:	57f78793          	addi	a5,a5,1407 # 464c457f <_entry-0x39b3ba81>
    80004c4e:	04f70663          	beq	a4,a5,80004c9a <exec+0xd0>

 bad:
  if(pagetable)
    proc_freepagetable(pagetable, sz);
  if(ip){
    iunlockput(ip);
    80004c52:	8556                	mv	a0,s5
    80004c54:	fffff097          	auipc	ra,0xfffff
    80004c58:	cd0080e7          	jalr	-816(ra) # 80003924 <iunlockput>
    end_op();
    80004c5c:	fffff097          	auipc	ra,0xfffff
    80004c60:	4a8080e7          	jalr	1192(ra) # 80004104 <end_op>
  }
  return -1;
    80004c64:	557d                	li	a0,-1
}
    80004c66:	21813083          	ld	ra,536(sp)
    80004c6a:	21013403          	ld	s0,528(sp)
    80004c6e:	20813483          	ld	s1,520(sp)
    80004c72:	20013903          	ld	s2,512(sp)
    80004c76:	79fe                	ld	s3,504(sp)
    80004c78:	7a5e                	ld	s4,496(sp)
    80004c7a:	7abe                	ld	s5,488(sp)
    80004c7c:	7b1e                	ld	s6,480(sp)
    80004c7e:	6bfe                	ld	s7,472(sp)
    80004c80:	6c5e                	ld	s8,464(sp)
    80004c82:	6cbe                	ld	s9,456(sp)
    80004c84:	6d1e                	ld	s10,448(sp)
    80004c86:	7dfa                	ld	s11,440(sp)
    80004c88:	22010113          	addi	sp,sp,544
    80004c8c:	8082                	ret
    end_op();
    80004c8e:	fffff097          	auipc	ra,0xfffff
    80004c92:	476080e7          	jalr	1142(ra) # 80004104 <end_op>
    return -1;
    80004c96:	557d                	li	a0,-1
    80004c98:	b7f9                	j	80004c66 <exec+0x9c>
  if((pagetable = proc_pagetable(p)) == 0)
    80004c9a:	8526                	mv	a0,s1
    80004c9c:	ffffd097          	auipc	ra,0xffffd
    80004ca0:	e52080e7          	jalr	-430(ra) # 80001aee <proc_pagetable>
    80004ca4:	8b2a                	mv	s6,a0
    80004ca6:	d555                	beqz	a0,80004c52 <exec+0x88>
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80004ca8:	e7042783          	lw	a5,-400(s0)
    80004cac:	e8845703          	lhu	a4,-376(s0)
    80004cb0:	c735                	beqz	a4,80004d1c <exec+0x152>
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
    80004cb2:	4901                	li	s2,0
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80004cb4:	e0043423          	sd	zero,-504(s0)
    if(ph.vaddr % PGSIZE != 0)
    80004cb8:	6a05                	lui	s4,0x1
    80004cba:	fffa0713          	addi	a4,s4,-1 # fff <_entry-0x7ffff001>
    80004cbe:	dee43023          	sd	a4,-544(s0)
loadseg(pagetable_t pagetable, uint64 va, struct inode *ip, uint offset, uint sz)
{
  uint i, n;
  uint64 pa;

  for(i = 0; i < sz; i += PGSIZE){
    80004cc2:	6d85                	lui	s11,0x1
    80004cc4:	7d7d                	lui	s10,0xfffff
    80004cc6:	a481                	j	80004f06 <exec+0x33c>
    pa = walkaddr(pagetable, va + i);
    if(pa == 0)
      panic("loadseg: address should exist");
    80004cc8:	00004517          	auipc	a0,0x4
    80004ccc:	a4850513          	addi	a0,a0,-1464 # 80008710 <syscalls+0x288>
    80004cd0:	ffffc097          	auipc	ra,0xffffc
    80004cd4:	86e080e7          	jalr	-1938(ra) # 8000053e <panic>
    if(sz - i < PGSIZE)
      n = sz - i;
    else
      n = PGSIZE;
    if(readi(ip, 0, (uint64)pa, offset+i, n) != n)
    80004cd8:	874a                	mv	a4,s2
    80004cda:	009c86bb          	addw	a3,s9,s1
    80004cde:	4581                	li	a1,0
    80004ce0:	8556                	mv	a0,s5
    80004ce2:	fffff097          	auipc	ra,0xfffff
    80004ce6:	c94080e7          	jalr	-876(ra) # 80003976 <readi>
    80004cea:	2501                	sext.w	a0,a0
    80004cec:	1aa91a63          	bne	s2,a0,80004ea0 <exec+0x2d6>
  for(i = 0; i < sz; i += PGSIZE){
    80004cf0:	009d84bb          	addw	s1,s11,s1
    80004cf4:	013d09bb          	addw	s3,s10,s3
    80004cf8:	1f74f763          	bgeu	s1,s7,80004ee6 <exec+0x31c>
    pa = walkaddr(pagetable, va + i);
    80004cfc:	02049593          	slli	a1,s1,0x20
    80004d00:	9181                	srli	a1,a1,0x20
    80004d02:	95e2                	add	a1,a1,s8
    80004d04:	855a                	mv	a0,s6
    80004d06:	ffffc097          	auipc	ra,0xffffc
    80004d0a:	3d4080e7          	jalr	980(ra) # 800010da <walkaddr>
    80004d0e:	862a                	mv	a2,a0
    if(pa == 0)
    80004d10:	dd45                	beqz	a0,80004cc8 <exec+0xfe>
      n = PGSIZE;
    80004d12:	8952                	mv	s2,s4
    if(sz - i < PGSIZE)
    80004d14:	fd49f2e3          	bgeu	s3,s4,80004cd8 <exec+0x10e>
      n = sz - i;
    80004d18:	894e                	mv	s2,s3
    80004d1a:	bf7d                	j	80004cd8 <exec+0x10e>
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
    80004d1c:	4901                	li	s2,0
  iunlockput(ip);
    80004d1e:	8556                	mv	a0,s5
    80004d20:	fffff097          	auipc	ra,0xfffff
    80004d24:	c04080e7          	jalr	-1020(ra) # 80003924 <iunlockput>
  end_op();
    80004d28:	fffff097          	auipc	ra,0xfffff
    80004d2c:	3dc080e7          	jalr	988(ra) # 80004104 <end_op>
  p = myproc();
    80004d30:	ffffd097          	auipc	ra,0xffffd
    80004d34:	cfa080e7          	jalr	-774(ra) # 80001a2a <myproc>
    80004d38:	8baa                	mv	s7,a0
  uint64 oldsz = p->sz;
    80004d3a:	04853d03          	ld	s10,72(a0)
  sz = PGROUNDUP(sz);
    80004d3e:	6785                	lui	a5,0x1
    80004d40:	17fd                	addi	a5,a5,-1
    80004d42:	993e                	add	s2,s2,a5
    80004d44:	77fd                	lui	a5,0xfffff
    80004d46:	00f977b3          	and	a5,s2,a5
    80004d4a:	def43c23          	sd	a5,-520(s0)
  if((sz1 = uvmalloc(pagetable, sz, sz + 2*PGSIZE, PTE_W)) == 0)
    80004d4e:	4691                	li	a3,4
    80004d50:	6609                	lui	a2,0x2
    80004d52:	963e                	add	a2,a2,a5
    80004d54:	85be                	mv	a1,a5
    80004d56:	855a                	mv	a0,s6
    80004d58:	ffffc097          	auipc	ra,0xffffc
    80004d5c:	736080e7          	jalr	1846(ra) # 8000148e <uvmalloc>
    80004d60:	8c2a                	mv	s8,a0
  ip = 0;
    80004d62:	4a81                	li	s5,0
  if((sz1 = uvmalloc(pagetable, sz, sz + 2*PGSIZE, PTE_W)) == 0)
    80004d64:	12050e63          	beqz	a0,80004ea0 <exec+0x2d6>
  uvmclear(pagetable, sz-2*PGSIZE);
    80004d68:	75f9                	lui	a1,0xffffe
    80004d6a:	95aa                	add	a1,a1,a0
    80004d6c:	855a                	mv	a0,s6
    80004d6e:	ffffd097          	auipc	ra,0xffffd
    80004d72:	946080e7          	jalr	-1722(ra) # 800016b4 <uvmclear>
  stackbase = sp - PGSIZE;
    80004d76:	7afd                	lui	s5,0xfffff
    80004d78:	9ae2                	add	s5,s5,s8
  for(argc = 0; argv[argc]; argc++) {
    80004d7a:	df043783          	ld	a5,-528(s0)
    80004d7e:	6388                	ld	a0,0(a5)
    80004d80:	c925                	beqz	a0,80004df0 <exec+0x226>
    80004d82:	e9040993          	addi	s3,s0,-368
    80004d86:	f9040c93          	addi	s9,s0,-112
  sp = sz;
    80004d8a:	8962                	mv	s2,s8
  for(argc = 0; argv[argc]; argc++) {
    80004d8c:	4481                	li	s1,0
    sp -= strlen(argv[argc]) + 1;
    80004d8e:	ffffc097          	auipc	ra,0xffffc
    80004d92:	124080e7          	jalr	292(ra) # 80000eb2 <strlen>
    80004d96:	0015079b          	addiw	a5,a0,1
    80004d9a:	40f90933          	sub	s2,s2,a5
    sp -= sp % 16; // riscv sp must be 16-byte aligned
    80004d9e:	ff097913          	andi	s2,s2,-16
    if(sp < stackbase)
    80004da2:	13596663          	bltu	s2,s5,80004ece <exec+0x304>
    if(copyout(pagetable, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
    80004da6:	df043d83          	ld	s11,-528(s0)
    80004daa:	000dba03          	ld	s4,0(s11) # 1000 <_entry-0x7ffff000>
    80004dae:	8552                	mv	a0,s4
    80004db0:	ffffc097          	auipc	ra,0xffffc
    80004db4:	102080e7          	jalr	258(ra) # 80000eb2 <strlen>
    80004db8:	0015069b          	addiw	a3,a0,1
    80004dbc:	8652                	mv	a2,s4
    80004dbe:	85ca                	mv	a1,s2
    80004dc0:	855a                	mv	a0,s6
    80004dc2:	ffffd097          	auipc	ra,0xffffd
    80004dc6:	924080e7          	jalr	-1756(ra) # 800016e6 <copyout>
    80004dca:	10054663          	bltz	a0,80004ed6 <exec+0x30c>
    ustack[argc] = sp;
    80004dce:	0129b023          	sd	s2,0(s3)
  for(argc = 0; argv[argc]; argc++) {
    80004dd2:	0485                	addi	s1,s1,1
    80004dd4:	008d8793          	addi	a5,s11,8
    80004dd8:	def43823          	sd	a5,-528(s0)
    80004ddc:	008db503          	ld	a0,8(s11)
    80004de0:	c911                	beqz	a0,80004df4 <exec+0x22a>
    if(argc >= MAXARG)
    80004de2:	09a1                	addi	s3,s3,8
    80004de4:	fb3c95e3          	bne	s9,s3,80004d8e <exec+0x1c4>
  sz = sz1;
    80004de8:	df843c23          	sd	s8,-520(s0)
  ip = 0;
    80004dec:	4a81                	li	s5,0
    80004dee:	a84d                	j	80004ea0 <exec+0x2d6>
  sp = sz;
    80004df0:	8962                	mv	s2,s8
  for(argc = 0; argv[argc]; argc++) {
    80004df2:	4481                	li	s1,0
  ustack[argc] = 0;
    80004df4:	00349793          	slli	a5,s1,0x3
    80004df8:	f9040713          	addi	a4,s0,-112
    80004dfc:	97ba                	add	a5,a5,a4
    80004dfe:	f007b023          	sd	zero,-256(a5) # ffffffffffffef00 <end+0xffffffff7ffdd180>
  sp -= (argc+1) * sizeof(uint64);
    80004e02:	00148693          	addi	a3,s1,1
    80004e06:	068e                	slli	a3,a3,0x3
    80004e08:	40d90933          	sub	s2,s2,a3
  sp -= sp % 16;
    80004e0c:	ff097913          	andi	s2,s2,-16
  if(sp < stackbase)
    80004e10:	01597663          	bgeu	s2,s5,80004e1c <exec+0x252>
  sz = sz1;
    80004e14:	df843c23          	sd	s8,-520(s0)
  ip = 0;
    80004e18:	4a81                	li	s5,0
    80004e1a:	a059                	j	80004ea0 <exec+0x2d6>
  if(copyout(pagetable, sp, (char *)ustack, (argc+1)*sizeof(uint64)) < 0)
    80004e1c:	e9040613          	addi	a2,s0,-368
    80004e20:	85ca                	mv	a1,s2
    80004e22:	855a                	mv	a0,s6
    80004e24:	ffffd097          	auipc	ra,0xffffd
    80004e28:	8c2080e7          	jalr	-1854(ra) # 800016e6 <copyout>
    80004e2c:	0a054963          	bltz	a0,80004ede <exec+0x314>
  p->trapframe->a1 = sp;
    80004e30:	058bb783          	ld	a5,88(s7) # 1058 <_entry-0x7fffefa8>
    80004e34:	0727bc23          	sd	s2,120(a5)
  for(last=s=path; *s; s++)
    80004e38:	de843783          	ld	a5,-536(s0)
    80004e3c:	0007c703          	lbu	a4,0(a5)
    80004e40:	cf11                	beqz	a4,80004e5c <exec+0x292>
    80004e42:	0785                	addi	a5,a5,1
    if(*s == '/')
    80004e44:	02f00693          	li	a3,47
    80004e48:	a039                	j	80004e56 <exec+0x28c>
      last = s+1;
    80004e4a:	def43423          	sd	a5,-536(s0)
  for(last=s=path; *s; s++)
    80004e4e:	0785                	addi	a5,a5,1
    80004e50:	fff7c703          	lbu	a4,-1(a5)
    80004e54:	c701                	beqz	a4,80004e5c <exec+0x292>
    if(*s == '/')
    80004e56:	fed71ce3          	bne	a4,a3,80004e4e <exec+0x284>
    80004e5a:	bfc5                	j	80004e4a <exec+0x280>
  safestrcpy(p->name, last, sizeof(p->name));
    80004e5c:	4641                	li	a2,16
    80004e5e:	de843583          	ld	a1,-536(s0)
    80004e62:	158b8513          	addi	a0,s7,344
    80004e66:	ffffc097          	auipc	ra,0xffffc
    80004e6a:	01a080e7          	jalr	26(ra) # 80000e80 <safestrcpy>
  oldpagetable = p->pagetable;
    80004e6e:	050bb503          	ld	a0,80(s7)
  p->pagetable = pagetable;
    80004e72:	056bb823          	sd	s6,80(s7)
  p->sz = sz;
    80004e76:	058bb423          	sd	s8,72(s7)
  p->trapframe->epc = elf.entry;  // initial program counter = main
    80004e7a:	058bb783          	ld	a5,88(s7)
    80004e7e:	e6843703          	ld	a4,-408(s0)
    80004e82:	ef98                	sd	a4,24(a5)
  p->trapframe->sp = sp; // initial stack pointer
    80004e84:	058bb783          	ld	a5,88(s7)
    80004e88:	0327b823          	sd	s2,48(a5)
  proc_freepagetable(oldpagetable, oldsz);
    80004e8c:	85ea                	mv	a1,s10
    80004e8e:	ffffd097          	auipc	ra,0xffffd
    80004e92:	cfc080e7          	jalr	-772(ra) # 80001b8a <proc_freepagetable>
  return argc; // this ends up in a0, the first argument to main(argc, argv)
    80004e96:	0004851b          	sext.w	a0,s1
    80004e9a:	b3f1                	j	80004c66 <exec+0x9c>
    80004e9c:	df243c23          	sd	s2,-520(s0)
    proc_freepagetable(pagetable, sz);
    80004ea0:	df843583          	ld	a1,-520(s0)
    80004ea4:	855a                	mv	a0,s6
    80004ea6:	ffffd097          	auipc	ra,0xffffd
    80004eaa:	ce4080e7          	jalr	-796(ra) # 80001b8a <proc_freepagetable>
  if(ip){
    80004eae:	da0a92e3          	bnez	s5,80004c52 <exec+0x88>
  return -1;
    80004eb2:	557d                	li	a0,-1
    80004eb4:	bb4d                	j	80004c66 <exec+0x9c>
    80004eb6:	df243c23          	sd	s2,-520(s0)
    80004eba:	b7dd                	j	80004ea0 <exec+0x2d6>
    80004ebc:	df243c23          	sd	s2,-520(s0)
    80004ec0:	b7c5                	j	80004ea0 <exec+0x2d6>
    80004ec2:	df243c23          	sd	s2,-520(s0)
    80004ec6:	bfe9                	j	80004ea0 <exec+0x2d6>
    80004ec8:	df243c23          	sd	s2,-520(s0)
    80004ecc:	bfd1                	j	80004ea0 <exec+0x2d6>
  sz = sz1;
    80004ece:	df843c23          	sd	s8,-520(s0)
  ip = 0;
    80004ed2:	4a81                	li	s5,0
    80004ed4:	b7f1                	j	80004ea0 <exec+0x2d6>
  sz = sz1;
    80004ed6:	df843c23          	sd	s8,-520(s0)
  ip = 0;
    80004eda:	4a81                	li	s5,0
    80004edc:	b7d1                	j	80004ea0 <exec+0x2d6>
  sz = sz1;
    80004ede:	df843c23          	sd	s8,-520(s0)
  ip = 0;
    80004ee2:	4a81                	li	s5,0
    80004ee4:	bf75                	j	80004ea0 <exec+0x2d6>
    if((sz1 = uvmalloc(pagetable, sz, ph.vaddr + ph.memsz, flags2perm(ph.flags))) == 0)
    80004ee6:	df843903          	ld	s2,-520(s0)
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80004eea:	e0843783          	ld	a5,-504(s0)
    80004eee:	0017869b          	addiw	a3,a5,1
    80004ef2:	e0d43423          	sd	a3,-504(s0)
    80004ef6:	e0043783          	ld	a5,-512(s0)
    80004efa:	0387879b          	addiw	a5,a5,56
    80004efe:	e8845703          	lhu	a4,-376(s0)
    80004f02:	e0e6dee3          	bge	a3,a4,80004d1e <exec+0x154>
    if(readi(ip, 0, (uint64)&ph, off, sizeof(ph)) != sizeof(ph))
    80004f06:	2781                	sext.w	a5,a5
    80004f08:	e0f43023          	sd	a5,-512(s0)
    80004f0c:	03800713          	li	a4,56
    80004f10:	86be                	mv	a3,a5
    80004f12:	e1840613          	addi	a2,s0,-488
    80004f16:	4581                	li	a1,0
    80004f18:	8556                	mv	a0,s5
    80004f1a:	fffff097          	auipc	ra,0xfffff
    80004f1e:	a5c080e7          	jalr	-1444(ra) # 80003976 <readi>
    80004f22:	03800793          	li	a5,56
    80004f26:	f6f51be3          	bne	a0,a5,80004e9c <exec+0x2d2>
    if(ph.type != ELF_PROG_LOAD)
    80004f2a:	e1842783          	lw	a5,-488(s0)
    80004f2e:	4705                	li	a4,1
    80004f30:	fae79de3          	bne	a5,a4,80004eea <exec+0x320>
    if(ph.memsz < ph.filesz)
    80004f34:	e4043483          	ld	s1,-448(s0)
    80004f38:	e3843783          	ld	a5,-456(s0)
    80004f3c:	f6f4ede3          	bltu	s1,a5,80004eb6 <exec+0x2ec>
    if(ph.vaddr + ph.memsz < ph.vaddr)
    80004f40:	e2843783          	ld	a5,-472(s0)
    80004f44:	94be                	add	s1,s1,a5
    80004f46:	f6f4ebe3          	bltu	s1,a5,80004ebc <exec+0x2f2>
    if(ph.vaddr % PGSIZE != 0)
    80004f4a:	de043703          	ld	a4,-544(s0)
    80004f4e:	8ff9                	and	a5,a5,a4
    80004f50:	fbad                	bnez	a5,80004ec2 <exec+0x2f8>
    if((sz1 = uvmalloc(pagetable, sz, ph.vaddr + ph.memsz, flags2perm(ph.flags))) == 0)
    80004f52:	e1c42503          	lw	a0,-484(s0)
    80004f56:	00000097          	auipc	ra,0x0
    80004f5a:	c58080e7          	jalr	-936(ra) # 80004bae <flags2perm>
    80004f5e:	86aa                	mv	a3,a0
    80004f60:	8626                	mv	a2,s1
    80004f62:	85ca                	mv	a1,s2
    80004f64:	855a                	mv	a0,s6
    80004f66:	ffffc097          	auipc	ra,0xffffc
    80004f6a:	528080e7          	jalr	1320(ra) # 8000148e <uvmalloc>
    80004f6e:	dea43c23          	sd	a0,-520(s0)
    80004f72:	d939                	beqz	a0,80004ec8 <exec+0x2fe>
    if(loadseg(pagetable, ph.vaddr, ip, ph.off, ph.filesz) < 0)
    80004f74:	e2843c03          	ld	s8,-472(s0)
    80004f78:	e2042c83          	lw	s9,-480(s0)
    80004f7c:	e3842b83          	lw	s7,-456(s0)
  for(i = 0; i < sz; i += PGSIZE){
    80004f80:	f60b83e3          	beqz	s7,80004ee6 <exec+0x31c>
    80004f84:	89de                	mv	s3,s7
    80004f86:	4481                	li	s1,0
    80004f88:	bb95                	j	80004cfc <exec+0x132>

0000000080004f8a <argfd>:

// Fetch the nth word-sized system call argument as a file descriptor
// and return both the descriptor and the corresponding struct file.
static int
argfd(int n, int *pfd, struct file **pf)
{
    80004f8a:	7179                	addi	sp,sp,-48
    80004f8c:	f406                	sd	ra,40(sp)
    80004f8e:	f022                	sd	s0,32(sp)
    80004f90:	ec26                	sd	s1,24(sp)
    80004f92:	e84a                	sd	s2,16(sp)
    80004f94:	1800                	addi	s0,sp,48
    80004f96:	892e                	mv	s2,a1
    80004f98:	84b2                	mv	s1,a2
  int fd;
  struct file *f;

  argint(n, &fd);
    80004f9a:	fdc40593          	addi	a1,s0,-36
    80004f9e:	ffffe097          	auipc	ra,0xffffe
    80004fa2:	ba0080e7          	jalr	-1120(ra) # 80002b3e <argint>
  if(fd < 0 || fd >= NOFILE || (f=myproc()->ofile[fd]) == 0)
    80004fa6:	fdc42703          	lw	a4,-36(s0)
    80004faa:	47bd                	li	a5,15
    80004fac:	02e7eb63          	bltu	a5,a4,80004fe2 <argfd+0x58>
    80004fb0:	ffffd097          	auipc	ra,0xffffd
    80004fb4:	a7a080e7          	jalr	-1414(ra) # 80001a2a <myproc>
    80004fb8:	fdc42703          	lw	a4,-36(s0)
    80004fbc:	01a70793          	addi	a5,a4,26
    80004fc0:	078e                	slli	a5,a5,0x3
    80004fc2:	953e                	add	a0,a0,a5
    80004fc4:	611c                	ld	a5,0(a0)
    80004fc6:	c385                	beqz	a5,80004fe6 <argfd+0x5c>
    return -1;
  if(pfd)
    80004fc8:	00090463          	beqz	s2,80004fd0 <argfd+0x46>
    *pfd = fd;
    80004fcc:	00e92023          	sw	a4,0(s2)
  if(pf)
    *pf = f;
  return 0;
    80004fd0:	4501                	li	a0,0
  if(pf)
    80004fd2:	c091                	beqz	s1,80004fd6 <argfd+0x4c>
    *pf = f;
    80004fd4:	e09c                	sd	a5,0(s1)
}
    80004fd6:	70a2                	ld	ra,40(sp)
    80004fd8:	7402                	ld	s0,32(sp)
    80004fda:	64e2                	ld	s1,24(sp)
    80004fdc:	6942                	ld	s2,16(sp)
    80004fde:	6145                	addi	sp,sp,48
    80004fe0:	8082                	ret
    return -1;
    80004fe2:	557d                	li	a0,-1
    80004fe4:	bfcd                	j	80004fd6 <argfd+0x4c>
    80004fe6:	557d                	li	a0,-1
    80004fe8:	b7fd                	j	80004fd6 <argfd+0x4c>

0000000080004fea <fdalloc>:

// Allocate a file descriptor for the given file.
// Takes over file reference from caller on success.
static int
fdalloc(struct file *f)
{
    80004fea:	1101                	addi	sp,sp,-32
    80004fec:	ec06                	sd	ra,24(sp)
    80004fee:	e822                	sd	s0,16(sp)
    80004ff0:	e426                	sd	s1,8(sp)
    80004ff2:	1000                	addi	s0,sp,32
    80004ff4:	84aa                	mv	s1,a0
  int fd;
  struct proc *p = myproc();
    80004ff6:	ffffd097          	auipc	ra,0xffffd
    80004ffa:	a34080e7          	jalr	-1484(ra) # 80001a2a <myproc>
    80004ffe:	862a                	mv	a2,a0

  for(fd = 0; fd < NOFILE; fd++){
    80005000:	0d050793          	addi	a5,a0,208
    80005004:	4501                	li	a0,0
    80005006:	46c1                	li	a3,16
    if(p->ofile[fd] == 0){
    80005008:	6398                	ld	a4,0(a5)
    8000500a:	cb19                	beqz	a4,80005020 <fdalloc+0x36>
  for(fd = 0; fd < NOFILE; fd++){
    8000500c:	2505                	addiw	a0,a0,1
    8000500e:	07a1                	addi	a5,a5,8
    80005010:	fed51ce3          	bne	a0,a3,80005008 <fdalloc+0x1e>
      p->ofile[fd] = f;
      return fd;
    }
  }
  return -1;
    80005014:	557d                	li	a0,-1
}
    80005016:	60e2                	ld	ra,24(sp)
    80005018:	6442                	ld	s0,16(sp)
    8000501a:	64a2                	ld	s1,8(sp)
    8000501c:	6105                	addi	sp,sp,32
    8000501e:	8082                	ret
      p->ofile[fd] = f;
    80005020:	01a50793          	addi	a5,a0,26
    80005024:	078e                	slli	a5,a5,0x3
    80005026:	963e                	add	a2,a2,a5
    80005028:	e204                	sd	s1,0(a2)
      return fd;
    8000502a:	b7f5                	j	80005016 <fdalloc+0x2c>

000000008000502c <create>:
  return -1;
}

static struct inode*
create(char *path, short type, short major, short minor)
{
    8000502c:	715d                	addi	sp,sp,-80
    8000502e:	e486                	sd	ra,72(sp)
    80005030:	e0a2                	sd	s0,64(sp)
    80005032:	fc26                	sd	s1,56(sp)
    80005034:	f84a                	sd	s2,48(sp)
    80005036:	f44e                	sd	s3,40(sp)
    80005038:	f052                	sd	s4,32(sp)
    8000503a:	ec56                	sd	s5,24(sp)
    8000503c:	e85a                	sd	s6,16(sp)
    8000503e:	0880                	addi	s0,sp,80
    80005040:	8b2e                	mv	s6,a1
    80005042:	89b2                	mv	s3,a2
    80005044:	8936                	mv	s2,a3
  struct inode *ip, *dp;
  char name[DIRSIZ];

  if((dp = nameiparent(path, name)) == 0)
    80005046:	fb040593          	addi	a1,s0,-80
    8000504a:	fffff097          	auipc	ra,0xfffff
    8000504e:	e3c080e7          	jalr	-452(ra) # 80003e86 <nameiparent>
    80005052:	84aa                	mv	s1,a0
    80005054:	14050f63          	beqz	a0,800051b2 <create+0x186>
    return 0;

  ilock(dp);
    80005058:	ffffe097          	auipc	ra,0xffffe
    8000505c:	66a080e7          	jalr	1642(ra) # 800036c2 <ilock>

  if((ip = dirlookup(dp, name, 0)) != 0){
    80005060:	4601                	li	a2,0
    80005062:	fb040593          	addi	a1,s0,-80
    80005066:	8526                	mv	a0,s1
    80005068:	fffff097          	auipc	ra,0xfffff
    8000506c:	b3e080e7          	jalr	-1218(ra) # 80003ba6 <dirlookup>
    80005070:	8aaa                	mv	s5,a0
    80005072:	c931                	beqz	a0,800050c6 <create+0x9a>
    iunlockput(dp);
    80005074:	8526                	mv	a0,s1
    80005076:	fffff097          	auipc	ra,0xfffff
    8000507a:	8ae080e7          	jalr	-1874(ra) # 80003924 <iunlockput>
    ilock(ip);
    8000507e:	8556                	mv	a0,s5
    80005080:	ffffe097          	auipc	ra,0xffffe
    80005084:	642080e7          	jalr	1602(ra) # 800036c2 <ilock>
    if(type == T_FILE && (ip->type == T_FILE || ip->type == T_DEVICE))
    80005088:	000b059b          	sext.w	a1,s6
    8000508c:	4789                	li	a5,2
    8000508e:	02f59563          	bne	a1,a5,800050b8 <create+0x8c>
    80005092:	044ad783          	lhu	a5,68(s5) # fffffffffffff044 <end+0xffffffff7ffdd2c4>
    80005096:	37f9                	addiw	a5,a5,-2
    80005098:	17c2                	slli	a5,a5,0x30
    8000509a:	93c1                	srli	a5,a5,0x30
    8000509c:	4705                	li	a4,1
    8000509e:	00f76d63          	bltu	a4,a5,800050b8 <create+0x8c>
  ip->nlink = 0;
  iupdate(ip);
  iunlockput(ip);
  iunlockput(dp);
  return 0;
}
    800050a2:	8556                	mv	a0,s5
    800050a4:	60a6                	ld	ra,72(sp)
    800050a6:	6406                	ld	s0,64(sp)
    800050a8:	74e2                	ld	s1,56(sp)
    800050aa:	7942                	ld	s2,48(sp)
    800050ac:	79a2                	ld	s3,40(sp)
    800050ae:	7a02                	ld	s4,32(sp)
    800050b0:	6ae2                	ld	s5,24(sp)
    800050b2:	6b42                	ld	s6,16(sp)
    800050b4:	6161                	addi	sp,sp,80
    800050b6:	8082                	ret
    iunlockput(ip);
    800050b8:	8556                	mv	a0,s5
    800050ba:	fffff097          	auipc	ra,0xfffff
    800050be:	86a080e7          	jalr	-1942(ra) # 80003924 <iunlockput>
    return 0;
    800050c2:	4a81                	li	s5,0
    800050c4:	bff9                	j	800050a2 <create+0x76>
  if((ip = ialloc(dp->dev, type)) == 0){
    800050c6:	85da                	mv	a1,s6
    800050c8:	4088                	lw	a0,0(s1)
    800050ca:	ffffe097          	auipc	ra,0xffffe
    800050ce:	45c080e7          	jalr	1116(ra) # 80003526 <ialloc>
    800050d2:	8a2a                	mv	s4,a0
    800050d4:	c539                	beqz	a0,80005122 <create+0xf6>
  ilock(ip);
    800050d6:	ffffe097          	auipc	ra,0xffffe
    800050da:	5ec080e7          	jalr	1516(ra) # 800036c2 <ilock>
  ip->major = major;
    800050de:	053a1323          	sh	s3,70(s4)
  ip->minor = minor;
    800050e2:	052a1423          	sh	s2,72(s4)
  ip->nlink = 1;
    800050e6:	4905                	li	s2,1
    800050e8:	052a1523          	sh	s2,74(s4)
  iupdate(ip);
    800050ec:	8552                	mv	a0,s4
    800050ee:	ffffe097          	auipc	ra,0xffffe
    800050f2:	50a080e7          	jalr	1290(ra) # 800035f8 <iupdate>
  if(type == T_DIR){  // Create . and .. entries.
    800050f6:	000b059b          	sext.w	a1,s6
    800050fa:	03258b63          	beq	a1,s2,80005130 <create+0x104>
  if(dirlink(dp, name, ip->inum) < 0)
    800050fe:	004a2603          	lw	a2,4(s4)
    80005102:	fb040593          	addi	a1,s0,-80
    80005106:	8526                	mv	a0,s1
    80005108:	fffff097          	auipc	ra,0xfffff
    8000510c:	cae080e7          	jalr	-850(ra) # 80003db6 <dirlink>
    80005110:	06054f63          	bltz	a0,8000518e <create+0x162>
  iunlockput(dp);
    80005114:	8526                	mv	a0,s1
    80005116:	fffff097          	auipc	ra,0xfffff
    8000511a:	80e080e7          	jalr	-2034(ra) # 80003924 <iunlockput>
  return ip;
    8000511e:	8ad2                	mv	s5,s4
    80005120:	b749                	j	800050a2 <create+0x76>
    iunlockput(dp);
    80005122:	8526                	mv	a0,s1
    80005124:	fffff097          	auipc	ra,0xfffff
    80005128:	800080e7          	jalr	-2048(ra) # 80003924 <iunlockput>
    return 0;
    8000512c:	8ad2                	mv	s5,s4
    8000512e:	bf95                	j	800050a2 <create+0x76>
    if(dirlink(ip, ".", ip->inum) < 0 || dirlink(ip, "..", dp->inum) < 0)
    80005130:	004a2603          	lw	a2,4(s4)
    80005134:	00003597          	auipc	a1,0x3
    80005138:	5fc58593          	addi	a1,a1,1532 # 80008730 <syscalls+0x2a8>
    8000513c:	8552                	mv	a0,s4
    8000513e:	fffff097          	auipc	ra,0xfffff
    80005142:	c78080e7          	jalr	-904(ra) # 80003db6 <dirlink>
    80005146:	04054463          	bltz	a0,8000518e <create+0x162>
    8000514a:	40d0                	lw	a2,4(s1)
    8000514c:	00003597          	auipc	a1,0x3
    80005150:	5ec58593          	addi	a1,a1,1516 # 80008738 <syscalls+0x2b0>
    80005154:	8552                	mv	a0,s4
    80005156:	fffff097          	auipc	ra,0xfffff
    8000515a:	c60080e7          	jalr	-928(ra) # 80003db6 <dirlink>
    8000515e:	02054863          	bltz	a0,8000518e <create+0x162>
  if(dirlink(dp, name, ip->inum) < 0)
    80005162:	004a2603          	lw	a2,4(s4)
    80005166:	fb040593          	addi	a1,s0,-80
    8000516a:	8526                	mv	a0,s1
    8000516c:	fffff097          	auipc	ra,0xfffff
    80005170:	c4a080e7          	jalr	-950(ra) # 80003db6 <dirlink>
    80005174:	00054d63          	bltz	a0,8000518e <create+0x162>
    dp->nlink++;  // for ".."
    80005178:	04a4d783          	lhu	a5,74(s1)
    8000517c:	2785                	addiw	a5,a5,1
    8000517e:	04f49523          	sh	a5,74(s1)
    iupdate(dp);
    80005182:	8526                	mv	a0,s1
    80005184:	ffffe097          	auipc	ra,0xffffe
    80005188:	474080e7          	jalr	1140(ra) # 800035f8 <iupdate>
    8000518c:	b761                	j	80005114 <create+0xe8>
  ip->nlink = 0;
    8000518e:	040a1523          	sh	zero,74(s4)
  iupdate(ip);
    80005192:	8552                	mv	a0,s4
    80005194:	ffffe097          	auipc	ra,0xffffe
    80005198:	464080e7          	jalr	1124(ra) # 800035f8 <iupdate>
  iunlockput(ip);
    8000519c:	8552                	mv	a0,s4
    8000519e:	ffffe097          	auipc	ra,0xffffe
    800051a2:	786080e7          	jalr	1926(ra) # 80003924 <iunlockput>
  iunlockput(dp);
    800051a6:	8526                	mv	a0,s1
    800051a8:	ffffe097          	auipc	ra,0xffffe
    800051ac:	77c080e7          	jalr	1916(ra) # 80003924 <iunlockput>
  return 0;
    800051b0:	bdcd                	j	800050a2 <create+0x76>
    return 0;
    800051b2:	8aaa                	mv	s5,a0
    800051b4:	b5fd                	j	800050a2 <create+0x76>

00000000800051b6 <sys_dup>:
{
    800051b6:	7179                	addi	sp,sp,-48
    800051b8:	f406                	sd	ra,40(sp)
    800051ba:	f022                	sd	s0,32(sp)
    800051bc:	ec26                	sd	s1,24(sp)
    800051be:	1800                	addi	s0,sp,48
  if(argfd(0, 0, &f) < 0)
    800051c0:	fd840613          	addi	a2,s0,-40
    800051c4:	4581                	li	a1,0
    800051c6:	4501                	li	a0,0
    800051c8:	00000097          	auipc	ra,0x0
    800051cc:	dc2080e7          	jalr	-574(ra) # 80004f8a <argfd>
    return -1;
    800051d0:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0)
    800051d2:	02054363          	bltz	a0,800051f8 <sys_dup+0x42>
  if((fd=fdalloc(f)) < 0)
    800051d6:	fd843503          	ld	a0,-40(s0)
    800051da:	00000097          	auipc	ra,0x0
    800051de:	e10080e7          	jalr	-496(ra) # 80004fea <fdalloc>
    800051e2:	84aa                	mv	s1,a0
    return -1;
    800051e4:	57fd                	li	a5,-1
  if((fd=fdalloc(f)) < 0)
    800051e6:	00054963          	bltz	a0,800051f8 <sys_dup+0x42>
  filedup(f);
    800051ea:	fd843503          	ld	a0,-40(s0)
    800051ee:	fffff097          	auipc	ra,0xfffff
    800051f2:	310080e7          	jalr	784(ra) # 800044fe <filedup>
  return fd;
    800051f6:	87a6                	mv	a5,s1
}
    800051f8:	853e                	mv	a0,a5
    800051fa:	70a2                	ld	ra,40(sp)
    800051fc:	7402                	ld	s0,32(sp)
    800051fe:	64e2                	ld	s1,24(sp)
    80005200:	6145                	addi	sp,sp,48
    80005202:	8082                	ret

0000000080005204 <sys_read>:
{
    80005204:	7179                	addi	sp,sp,-48
    80005206:	f406                	sd	ra,40(sp)
    80005208:	f022                	sd	s0,32(sp)
    8000520a:	1800                	addi	s0,sp,48
  argaddr(1, &p);
    8000520c:	fd840593          	addi	a1,s0,-40
    80005210:	4505                	li	a0,1
    80005212:	ffffe097          	auipc	ra,0xffffe
    80005216:	94c080e7          	jalr	-1716(ra) # 80002b5e <argaddr>
  argint(2, &n);
    8000521a:	fe440593          	addi	a1,s0,-28
    8000521e:	4509                	li	a0,2
    80005220:	ffffe097          	auipc	ra,0xffffe
    80005224:	91e080e7          	jalr	-1762(ra) # 80002b3e <argint>
  if(argfd(0, 0, &f) < 0)
    80005228:	fe840613          	addi	a2,s0,-24
    8000522c:	4581                	li	a1,0
    8000522e:	4501                	li	a0,0
    80005230:	00000097          	auipc	ra,0x0
    80005234:	d5a080e7          	jalr	-678(ra) # 80004f8a <argfd>
    80005238:	87aa                	mv	a5,a0
    return -1;
    8000523a:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    8000523c:	0007cc63          	bltz	a5,80005254 <sys_read+0x50>
  return fileread(f, p, n);
    80005240:	fe442603          	lw	a2,-28(s0)
    80005244:	fd843583          	ld	a1,-40(s0)
    80005248:	fe843503          	ld	a0,-24(s0)
    8000524c:	fffff097          	auipc	ra,0xfffff
    80005250:	43e080e7          	jalr	1086(ra) # 8000468a <fileread>
}
    80005254:	70a2                	ld	ra,40(sp)
    80005256:	7402                	ld	s0,32(sp)
    80005258:	6145                	addi	sp,sp,48
    8000525a:	8082                	ret

000000008000525c <sys_write>:
{
    8000525c:	7179                	addi	sp,sp,-48
    8000525e:	f406                	sd	ra,40(sp)
    80005260:	f022                	sd	s0,32(sp)
    80005262:	1800                	addi	s0,sp,48
  argaddr(1, &p);
    80005264:	fd840593          	addi	a1,s0,-40
    80005268:	4505                	li	a0,1
    8000526a:	ffffe097          	auipc	ra,0xffffe
    8000526e:	8f4080e7          	jalr	-1804(ra) # 80002b5e <argaddr>
  argint(2, &n);
    80005272:	fe440593          	addi	a1,s0,-28
    80005276:	4509                	li	a0,2
    80005278:	ffffe097          	auipc	ra,0xffffe
    8000527c:	8c6080e7          	jalr	-1850(ra) # 80002b3e <argint>
  if(argfd(0, 0, &f) < 0)
    80005280:	fe840613          	addi	a2,s0,-24
    80005284:	4581                	li	a1,0
    80005286:	4501                	li	a0,0
    80005288:	00000097          	auipc	ra,0x0
    8000528c:	d02080e7          	jalr	-766(ra) # 80004f8a <argfd>
    80005290:	87aa                	mv	a5,a0
    return -1;
    80005292:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    80005294:	0007cc63          	bltz	a5,800052ac <sys_write+0x50>
  return filewrite(f, p, n);
    80005298:	fe442603          	lw	a2,-28(s0)
    8000529c:	fd843583          	ld	a1,-40(s0)
    800052a0:	fe843503          	ld	a0,-24(s0)
    800052a4:	fffff097          	auipc	ra,0xfffff
    800052a8:	4a8080e7          	jalr	1192(ra) # 8000474c <filewrite>
}
    800052ac:	70a2                	ld	ra,40(sp)
    800052ae:	7402                	ld	s0,32(sp)
    800052b0:	6145                	addi	sp,sp,48
    800052b2:	8082                	ret

00000000800052b4 <sys_close>:
{
    800052b4:	1101                	addi	sp,sp,-32
    800052b6:	ec06                	sd	ra,24(sp)
    800052b8:	e822                	sd	s0,16(sp)
    800052ba:	1000                	addi	s0,sp,32
  if(argfd(0, &fd, &f) < 0)
    800052bc:	fe040613          	addi	a2,s0,-32
    800052c0:	fec40593          	addi	a1,s0,-20
    800052c4:	4501                	li	a0,0
    800052c6:	00000097          	auipc	ra,0x0
    800052ca:	cc4080e7          	jalr	-828(ra) # 80004f8a <argfd>
    return -1;
    800052ce:	57fd                	li	a5,-1
  if(argfd(0, &fd, &f) < 0)
    800052d0:	02054463          	bltz	a0,800052f8 <sys_close+0x44>
  myproc()->ofile[fd] = 0;
    800052d4:	ffffc097          	auipc	ra,0xffffc
    800052d8:	756080e7          	jalr	1878(ra) # 80001a2a <myproc>
    800052dc:	fec42783          	lw	a5,-20(s0)
    800052e0:	07e9                	addi	a5,a5,26
    800052e2:	078e                	slli	a5,a5,0x3
    800052e4:	97aa                	add	a5,a5,a0
    800052e6:	0007b023          	sd	zero,0(a5)
  fileclose(f);
    800052ea:	fe043503          	ld	a0,-32(s0)
    800052ee:	fffff097          	auipc	ra,0xfffff
    800052f2:	262080e7          	jalr	610(ra) # 80004550 <fileclose>
  return 0;
    800052f6:	4781                	li	a5,0
}
    800052f8:	853e                	mv	a0,a5
    800052fa:	60e2                	ld	ra,24(sp)
    800052fc:	6442                	ld	s0,16(sp)
    800052fe:	6105                	addi	sp,sp,32
    80005300:	8082                	ret

0000000080005302 <sys_fstat>:
{
    80005302:	1101                	addi	sp,sp,-32
    80005304:	ec06                	sd	ra,24(sp)
    80005306:	e822                	sd	s0,16(sp)
    80005308:	1000                	addi	s0,sp,32
  argaddr(1, &st);
    8000530a:	fe040593          	addi	a1,s0,-32
    8000530e:	4505                	li	a0,1
    80005310:	ffffe097          	auipc	ra,0xffffe
    80005314:	84e080e7          	jalr	-1970(ra) # 80002b5e <argaddr>
  if(argfd(0, 0, &f) < 0)
    80005318:	fe840613          	addi	a2,s0,-24
    8000531c:	4581                	li	a1,0
    8000531e:	4501                	li	a0,0
    80005320:	00000097          	auipc	ra,0x0
    80005324:	c6a080e7          	jalr	-918(ra) # 80004f8a <argfd>
    80005328:	87aa                	mv	a5,a0
    return -1;
    8000532a:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    8000532c:	0007ca63          	bltz	a5,80005340 <sys_fstat+0x3e>
  return filestat(f, st);
    80005330:	fe043583          	ld	a1,-32(s0)
    80005334:	fe843503          	ld	a0,-24(s0)
    80005338:	fffff097          	auipc	ra,0xfffff
    8000533c:	2e0080e7          	jalr	736(ra) # 80004618 <filestat>
}
    80005340:	60e2                	ld	ra,24(sp)
    80005342:	6442                	ld	s0,16(sp)
    80005344:	6105                	addi	sp,sp,32
    80005346:	8082                	ret

0000000080005348 <sys_link>:
{
    80005348:	7169                	addi	sp,sp,-304
    8000534a:	f606                	sd	ra,296(sp)
    8000534c:	f222                	sd	s0,288(sp)
    8000534e:	ee26                	sd	s1,280(sp)
    80005350:	ea4a                	sd	s2,272(sp)
    80005352:	1a00                	addi	s0,sp,304
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80005354:	08000613          	li	a2,128
    80005358:	ed040593          	addi	a1,s0,-304
    8000535c:	4501                	li	a0,0
    8000535e:	ffffe097          	auipc	ra,0xffffe
    80005362:	820080e7          	jalr	-2016(ra) # 80002b7e <argstr>
    return -1;
    80005366:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80005368:	10054e63          	bltz	a0,80005484 <sys_link+0x13c>
    8000536c:	08000613          	li	a2,128
    80005370:	f5040593          	addi	a1,s0,-176
    80005374:	4505                	li	a0,1
    80005376:	ffffe097          	auipc	ra,0xffffe
    8000537a:	808080e7          	jalr	-2040(ra) # 80002b7e <argstr>
    return -1;
    8000537e:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80005380:	10054263          	bltz	a0,80005484 <sys_link+0x13c>
  begin_op();
    80005384:	fffff097          	auipc	ra,0xfffff
    80005388:	d00080e7          	jalr	-768(ra) # 80004084 <begin_op>
  if((ip = namei(old)) == 0){
    8000538c:	ed040513          	addi	a0,s0,-304
    80005390:	fffff097          	auipc	ra,0xfffff
    80005394:	ad8080e7          	jalr	-1320(ra) # 80003e68 <namei>
    80005398:	84aa                	mv	s1,a0
    8000539a:	c551                	beqz	a0,80005426 <sys_link+0xde>
  ilock(ip);
    8000539c:	ffffe097          	auipc	ra,0xffffe
    800053a0:	326080e7          	jalr	806(ra) # 800036c2 <ilock>
  if(ip->type == T_DIR){
    800053a4:	04449703          	lh	a4,68(s1)
    800053a8:	4785                	li	a5,1
    800053aa:	08f70463          	beq	a4,a5,80005432 <sys_link+0xea>
  ip->nlink++;
    800053ae:	04a4d783          	lhu	a5,74(s1)
    800053b2:	2785                	addiw	a5,a5,1
    800053b4:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    800053b8:	8526                	mv	a0,s1
    800053ba:	ffffe097          	auipc	ra,0xffffe
    800053be:	23e080e7          	jalr	574(ra) # 800035f8 <iupdate>
  iunlock(ip);
    800053c2:	8526                	mv	a0,s1
    800053c4:	ffffe097          	auipc	ra,0xffffe
    800053c8:	3c0080e7          	jalr	960(ra) # 80003784 <iunlock>
  if((dp = nameiparent(new, name)) == 0)
    800053cc:	fd040593          	addi	a1,s0,-48
    800053d0:	f5040513          	addi	a0,s0,-176
    800053d4:	fffff097          	auipc	ra,0xfffff
    800053d8:	ab2080e7          	jalr	-1358(ra) # 80003e86 <nameiparent>
    800053dc:	892a                	mv	s2,a0
    800053de:	c935                	beqz	a0,80005452 <sys_link+0x10a>
  ilock(dp);
    800053e0:	ffffe097          	auipc	ra,0xffffe
    800053e4:	2e2080e7          	jalr	738(ra) # 800036c2 <ilock>
  if(dp->dev != ip->dev || dirlink(dp, name, ip->inum) < 0){
    800053e8:	00092703          	lw	a4,0(s2)
    800053ec:	409c                	lw	a5,0(s1)
    800053ee:	04f71d63          	bne	a4,a5,80005448 <sys_link+0x100>
    800053f2:	40d0                	lw	a2,4(s1)
    800053f4:	fd040593          	addi	a1,s0,-48
    800053f8:	854a                	mv	a0,s2
    800053fa:	fffff097          	auipc	ra,0xfffff
    800053fe:	9bc080e7          	jalr	-1604(ra) # 80003db6 <dirlink>
    80005402:	04054363          	bltz	a0,80005448 <sys_link+0x100>
  iunlockput(dp);
    80005406:	854a                	mv	a0,s2
    80005408:	ffffe097          	auipc	ra,0xffffe
    8000540c:	51c080e7          	jalr	1308(ra) # 80003924 <iunlockput>
  iput(ip);
    80005410:	8526                	mv	a0,s1
    80005412:	ffffe097          	auipc	ra,0xffffe
    80005416:	46a080e7          	jalr	1130(ra) # 8000387c <iput>
  end_op();
    8000541a:	fffff097          	auipc	ra,0xfffff
    8000541e:	cea080e7          	jalr	-790(ra) # 80004104 <end_op>
  return 0;
    80005422:	4781                	li	a5,0
    80005424:	a085                	j	80005484 <sys_link+0x13c>
    end_op();
    80005426:	fffff097          	auipc	ra,0xfffff
    8000542a:	cde080e7          	jalr	-802(ra) # 80004104 <end_op>
    return -1;
    8000542e:	57fd                	li	a5,-1
    80005430:	a891                	j	80005484 <sys_link+0x13c>
    iunlockput(ip);
    80005432:	8526                	mv	a0,s1
    80005434:	ffffe097          	auipc	ra,0xffffe
    80005438:	4f0080e7          	jalr	1264(ra) # 80003924 <iunlockput>
    end_op();
    8000543c:	fffff097          	auipc	ra,0xfffff
    80005440:	cc8080e7          	jalr	-824(ra) # 80004104 <end_op>
    return -1;
    80005444:	57fd                	li	a5,-1
    80005446:	a83d                	j	80005484 <sys_link+0x13c>
    iunlockput(dp);
    80005448:	854a                	mv	a0,s2
    8000544a:	ffffe097          	auipc	ra,0xffffe
    8000544e:	4da080e7          	jalr	1242(ra) # 80003924 <iunlockput>
  ilock(ip);
    80005452:	8526                	mv	a0,s1
    80005454:	ffffe097          	auipc	ra,0xffffe
    80005458:	26e080e7          	jalr	622(ra) # 800036c2 <ilock>
  ip->nlink--;
    8000545c:	04a4d783          	lhu	a5,74(s1)
    80005460:	37fd                	addiw	a5,a5,-1
    80005462:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    80005466:	8526                	mv	a0,s1
    80005468:	ffffe097          	auipc	ra,0xffffe
    8000546c:	190080e7          	jalr	400(ra) # 800035f8 <iupdate>
  iunlockput(ip);
    80005470:	8526                	mv	a0,s1
    80005472:	ffffe097          	auipc	ra,0xffffe
    80005476:	4b2080e7          	jalr	1202(ra) # 80003924 <iunlockput>
  end_op();
    8000547a:	fffff097          	auipc	ra,0xfffff
    8000547e:	c8a080e7          	jalr	-886(ra) # 80004104 <end_op>
  return -1;
    80005482:	57fd                	li	a5,-1
}
    80005484:	853e                	mv	a0,a5
    80005486:	70b2                	ld	ra,296(sp)
    80005488:	7412                	ld	s0,288(sp)
    8000548a:	64f2                	ld	s1,280(sp)
    8000548c:	6952                	ld	s2,272(sp)
    8000548e:	6155                	addi	sp,sp,304
    80005490:	8082                	ret

0000000080005492 <sys_unlink>:
{
    80005492:	7151                	addi	sp,sp,-240
    80005494:	f586                	sd	ra,232(sp)
    80005496:	f1a2                	sd	s0,224(sp)
    80005498:	eda6                	sd	s1,216(sp)
    8000549a:	e9ca                	sd	s2,208(sp)
    8000549c:	e5ce                	sd	s3,200(sp)
    8000549e:	1980                	addi	s0,sp,240
  if(argstr(0, path, MAXPATH) < 0)
    800054a0:	08000613          	li	a2,128
    800054a4:	f3040593          	addi	a1,s0,-208
    800054a8:	4501                	li	a0,0
    800054aa:	ffffd097          	auipc	ra,0xffffd
    800054ae:	6d4080e7          	jalr	1748(ra) # 80002b7e <argstr>
    800054b2:	18054163          	bltz	a0,80005634 <sys_unlink+0x1a2>
  begin_op();
    800054b6:	fffff097          	auipc	ra,0xfffff
    800054ba:	bce080e7          	jalr	-1074(ra) # 80004084 <begin_op>
  if((dp = nameiparent(path, name)) == 0){
    800054be:	fb040593          	addi	a1,s0,-80
    800054c2:	f3040513          	addi	a0,s0,-208
    800054c6:	fffff097          	auipc	ra,0xfffff
    800054ca:	9c0080e7          	jalr	-1600(ra) # 80003e86 <nameiparent>
    800054ce:	84aa                	mv	s1,a0
    800054d0:	c979                	beqz	a0,800055a6 <sys_unlink+0x114>
  ilock(dp);
    800054d2:	ffffe097          	auipc	ra,0xffffe
    800054d6:	1f0080e7          	jalr	496(ra) # 800036c2 <ilock>
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
    800054da:	00003597          	auipc	a1,0x3
    800054de:	25658593          	addi	a1,a1,598 # 80008730 <syscalls+0x2a8>
    800054e2:	fb040513          	addi	a0,s0,-80
    800054e6:	ffffe097          	auipc	ra,0xffffe
    800054ea:	6a6080e7          	jalr	1702(ra) # 80003b8c <namecmp>
    800054ee:	14050a63          	beqz	a0,80005642 <sys_unlink+0x1b0>
    800054f2:	00003597          	auipc	a1,0x3
    800054f6:	24658593          	addi	a1,a1,582 # 80008738 <syscalls+0x2b0>
    800054fa:	fb040513          	addi	a0,s0,-80
    800054fe:	ffffe097          	auipc	ra,0xffffe
    80005502:	68e080e7          	jalr	1678(ra) # 80003b8c <namecmp>
    80005506:	12050e63          	beqz	a0,80005642 <sys_unlink+0x1b0>
  if((ip = dirlookup(dp, name, &off)) == 0)
    8000550a:	f2c40613          	addi	a2,s0,-212
    8000550e:	fb040593          	addi	a1,s0,-80
    80005512:	8526                	mv	a0,s1
    80005514:	ffffe097          	auipc	ra,0xffffe
    80005518:	692080e7          	jalr	1682(ra) # 80003ba6 <dirlookup>
    8000551c:	892a                	mv	s2,a0
    8000551e:	12050263          	beqz	a0,80005642 <sys_unlink+0x1b0>
  ilock(ip);
    80005522:	ffffe097          	auipc	ra,0xffffe
    80005526:	1a0080e7          	jalr	416(ra) # 800036c2 <ilock>
  if(ip->nlink < 1)
    8000552a:	04a91783          	lh	a5,74(s2)
    8000552e:	08f05263          	blez	a5,800055b2 <sys_unlink+0x120>
  if(ip->type == T_DIR && !isdirempty(ip)){
    80005532:	04491703          	lh	a4,68(s2)
    80005536:	4785                	li	a5,1
    80005538:	08f70563          	beq	a4,a5,800055c2 <sys_unlink+0x130>
  memset(&de, 0, sizeof(de));
    8000553c:	4641                	li	a2,16
    8000553e:	4581                	li	a1,0
    80005540:	fc040513          	addi	a0,s0,-64
    80005544:	ffffb097          	auipc	ra,0xffffb
    80005548:	7f2080e7          	jalr	2034(ra) # 80000d36 <memset>
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    8000554c:	4741                	li	a4,16
    8000554e:	f2c42683          	lw	a3,-212(s0)
    80005552:	fc040613          	addi	a2,s0,-64
    80005556:	4581                	li	a1,0
    80005558:	8526                	mv	a0,s1
    8000555a:	ffffe097          	auipc	ra,0xffffe
    8000555e:	514080e7          	jalr	1300(ra) # 80003a6e <writei>
    80005562:	47c1                	li	a5,16
    80005564:	0af51563          	bne	a0,a5,8000560e <sys_unlink+0x17c>
  if(ip->type == T_DIR){
    80005568:	04491703          	lh	a4,68(s2)
    8000556c:	4785                	li	a5,1
    8000556e:	0af70863          	beq	a4,a5,8000561e <sys_unlink+0x18c>
  iunlockput(dp);
    80005572:	8526                	mv	a0,s1
    80005574:	ffffe097          	auipc	ra,0xffffe
    80005578:	3b0080e7          	jalr	944(ra) # 80003924 <iunlockput>
  ip->nlink--;
    8000557c:	04a95783          	lhu	a5,74(s2)
    80005580:	37fd                	addiw	a5,a5,-1
    80005582:	04f91523          	sh	a5,74(s2)
  iupdate(ip);
    80005586:	854a                	mv	a0,s2
    80005588:	ffffe097          	auipc	ra,0xffffe
    8000558c:	070080e7          	jalr	112(ra) # 800035f8 <iupdate>
  iunlockput(ip);
    80005590:	854a                	mv	a0,s2
    80005592:	ffffe097          	auipc	ra,0xffffe
    80005596:	392080e7          	jalr	914(ra) # 80003924 <iunlockput>
  end_op();
    8000559a:	fffff097          	auipc	ra,0xfffff
    8000559e:	b6a080e7          	jalr	-1174(ra) # 80004104 <end_op>
  return 0;
    800055a2:	4501                	li	a0,0
    800055a4:	a84d                	j	80005656 <sys_unlink+0x1c4>
    end_op();
    800055a6:	fffff097          	auipc	ra,0xfffff
    800055aa:	b5e080e7          	jalr	-1186(ra) # 80004104 <end_op>
    return -1;
    800055ae:	557d                	li	a0,-1
    800055b0:	a05d                	j	80005656 <sys_unlink+0x1c4>
    panic("unlink: nlink < 1");
    800055b2:	00003517          	auipc	a0,0x3
    800055b6:	18e50513          	addi	a0,a0,398 # 80008740 <syscalls+0x2b8>
    800055ba:	ffffb097          	auipc	ra,0xffffb
    800055be:	f84080e7          	jalr	-124(ra) # 8000053e <panic>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    800055c2:	04c92703          	lw	a4,76(s2)
    800055c6:	02000793          	li	a5,32
    800055ca:	f6e7f9e3          	bgeu	a5,a4,8000553c <sys_unlink+0xaa>
    800055ce:	02000993          	li	s3,32
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    800055d2:	4741                	li	a4,16
    800055d4:	86ce                	mv	a3,s3
    800055d6:	f1840613          	addi	a2,s0,-232
    800055da:	4581                	li	a1,0
    800055dc:	854a                	mv	a0,s2
    800055de:	ffffe097          	auipc	ra,0xffffe
    800055e2:	398080e7          	jalr	920(ra) # 80003976 <readi>
    800055e6:	47c1                	li	a5,16
    800055e8:	00f51b63          	bne	a0,a5,800055fe <sys_unlink+0x16c>
    if(de.inum != 0)
    800055ec:	f1845783          	lhu	a5,-232(s0)
    800055f0:	e7a1                	bnez	a5,80005638 <sys_unlink+0x1a6>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    800055f2:	29c1                	addiw	s3,s3,16
    800055f4:	04c92783          	lw	a5,76(s2)
    800055f8:	fcf9ede3          	bltu	s3,a5,800055d2 <sys_unlink+0x140>
    800055fc:	b781                	j	8000553c <sys_unlink+0xaa>
      panic("isdirempty: readi");
    800055fe:	00003517          	auipc	a0,0x3
    80005602:	15a50513          	addi	a0,a0,346 # 80008758 <syscalls+0x2d0>
    80005606:	ffffb097          	auipc	ra,0xffffb
    8000560a:	f38080e7          	jalr	-200(ra) # 8000053e <panic>
    panic("unlink: writei");
    8000560e:	00003517          	auipc	a0,0x3
    80005612:	16250513          	addi	a0,a0,354 # 80008770 <syscalls+0x2e8>
    80005616:	ffffb097          	auipc	ra,0xffffb
    8000561a:	f28080e7          	jalr	-216(ra) # 8000053e <panic>
    dp->nlink--;
    8000561e:	04a4d783          	lhu	a5,74(s1)
    80005622:	37fd                	addiw	a5,a5,-1
    80005624:	04f49523          	sh	a5,74(s1)
    iupdate(dp);
    80005628:	8526                	mv	a0,s1
    8000562a:	ffffe097          	auipc	ra,0xffffe
    8000562e:	fce080e7          	jalr	-50(ra) # 800035f8 <iupdate>
    80005632:	b781                	j	80005572 <sys_unlink+0xe0>
    return -1;
    80005634:	557d                	li	a0,-1
    80005636:	a005                	j	80005656 <sys_unlink+0x1c4>
    iunlockput(ip);
    80005638:	854a                	mv	a0,s2
    8000563a:	ffffe097          	auipc	ra,0xffffe
    8000563e:	2ea080e7          	jalr	746(ra) # 80003924 <iunlockput>
  iunlockput(dp);
    80005642:	8526                	mv	a0,s1
    80005644:	ffffe097          	auipc	ra,0xffffe
    80005648:	2e0080e7          	jalr	736(ra) # 80003924 <iunlockput>
  end_op();
    8000564c:	fffff097          	auipc	ra,0xfffff
    80005650:	ab8080e7          	jalr	-1352(ra) # 80004104 <end_op>
  return -1;
    80005654:	557d                	li	a0,-1
}
    80005656:	70ae                	ld	ra,232(sp)
    80005658:	740e                	ld	s0,224(sp)
    8000565a:	64ee                	ld	s1,216(sp)
    8000565c:	694e                	ld	s2,208(sp)
    8000565e:	69ae                	ld	s3,200(sp)
    80005660:	616d                	addi	sp,sp,240
    80005662:	8082                	ret

0000000080005664 <sys_open>:

uint64
sys_open(void)
{
    80005664:	7131                	addi	sp,sp,-192
    80005666:	fd06                	sd	ra,184(sp)
    80005668:	f922                	sd	s0,176(sp)
    8000566a:	f526                	sd	s1,168(sp)
    8000566c:	f14a                	sd	s2,160(sp)
    8000566e:	ed4e                	sd	s3,152(sp)
    80005670:	0180                	addi	s0,sp,192
  int fd, omode;
  struct file *f;
  struct inode *ip;
  int n;

  argint(1, &omode);
    80005672:	f4c40593          	addi	a1,s0,-180
    80005676:	4505                	li	a0,1
    80005678:	ffffd097          	auipc	ra,0xffffd
    8000567c:	4c6080e7          	jalr	1222(ra) # 80002b3e <argint>
  if((n = argstr(0, path, MAXPATH)) < 0)
    80005680:	08000613          	li	a2,128
    80005684:	f5040593          	addi	a1,s0,-176
    80005688:	4501                	li	a0,0
    8000568a:	ffffd097          	auipc	ra,0xffffd
    8000568e:	4f4080e7          	jalr	1268(ra) # 80002b7e <argstr>
    80005692:	87aa                	mv	a5,a0
    return -1;
    80005694:	557d                	li	a0,-1
  if((n = argstr(0, path, MAXPATH)) < 0)
    80005696:	0a07c963          	bltz	a5,80005748 <sys_open+0xe4>

  begin_op();
    8000569a:	fffff097          	auipc	ra,0xfffff
    8000569e:	9ea080e7          	jalr	-1558(ra) # 80004084 <begin_op>

  if(omode & O_CREATE){
    800056a2:	f4c42783          	lw	a5,-180(s0)
    800056a6:	2007f793          	andi	a5,a5,512
    800056aa:	cfc5                	beqz	a5,80005762 <sys_open+0xfe>
    ip = create(path, T_FILE, 0, 0);
    800056ac:	4681                	li	a3,0
    800056ae:	4601                	li	a2,0
    800056b0:	4589                	li	a1,2
    800056b2:	f5040513          	addi	a0,s0,-176
    800056b6:	00000097          	auipc	ra,0x0
    800056ba:	976080e7          	jalr	-1674(ra) # 8000502c <create>
    800056be:	84aa                	mv	s1,a0
    if(ip == 0){
    800056c0:	c959                	beqz	a0,80005756 <sys_open+0xf2>
      end_op();
      return -1;
    }
  }

  if(ip->type == T_DEVICE && (ip->major < 0 || ip->major >= NDEV)){
    800056c2:	04449703          	lh	a4,68(s1)
    800056c6:	478d                	li	a5,3
    800056c8:	00f71763          	bne	a4,a5,800056d6 <sys_open+0x72>
    800056cc:	0464d703          	lhu	a4,70(s1)
    800056d0:	47a5                	li	a5,9
    800056d2:	0ce7ed63          	bltu	a5,a4,800057ac <sys_open+0x148>
    iunlockput(ip);
    end_op();
    return -1;
  }

  if((f = filealloc()) == 0 || (fd = fdalloc(f)) < 0){
    800056d6:	fffff097          	auipc	ra,0xfffff
    800056da:	dbe080e7          	jalr	-578(ra) # 80004494 <filealloc>
    800056de:	89aa                	mv	s3,a0
    800056e0:	10050363          	beqz	a0,800057e6 <sys_open+0x182>
    800056e4:	00000097          	auipc	ra,0x0
    800056e8:	906080e7          	jalr	-1786(ra) # 80004fea <fdalloc>
    800056ec:	892a                	mv	s2,a0
    800056ee:	0e054763          	bltz	a0,800057dc <sys_open+0x178>
    iunlockput(ip);
    end_op();
    return -1;
  }

  if(ip->type == T_DEVICE){
    800056f2:	04449703          	lh	a4,68(s1)
    800056f6:	478d                	li	a5,3
    800056f8:	0cf70563          	beq	a4,a5,800057c2 <sys_open+0x15e>
    f->type = FD_DEVICE;
    f->major = ip->major;
  } else {
    f->type = FD_INODE;
    800056fc:	4789                	li	a5,2
    800056fe:	00f9a023          	sw	a5,0(s3)
    f->off = 0;
    80005702:	0209a023          	sw	zero,32(s3)
  }
  f->ip = ip;
    80005706:	0099bc23          	sd	s1,24(s3)
  f->readable = !(omode & O_WRONLY);
    8000570a:	f4c42783          	lw	a5,-180(s0)
    8000570e:	0017c713          	xori	a4,a5,1
    80005712:	8b05                	andi	a4,a4,1
    80005714:	00e98423          	sb	a4,8(s3)
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
    80005718:	0037f713          	andi	a4,a5,3
    8000571c:	00e03733          	snez	a4,a4
    80005720:	00e984a3          	sb	a4,9(s3)

  if((omode & O_TRUNC) && ip->type == T_FILE){
    80005724:	4007f793          	andi	a5,a5,1024
    80005728:	c791                	beqz	a5,80005734 <sys_open+0xd0>
    8000572a:	04449703          	lh	a4,68(s1)
    8000572e:	4789                	li	a5,2
    80005730:	0af70063          	beq	a4,a5,800057d0 <sys_open+0x16c>
    itrunc(ip);
  }

  iunlock(ip);
    80005734:	8526                	mv	a0,s1
    80005736:	ffffe097          	auipc	ra,0xffffe
    8000573a:	04e080e7          	jalr	78(ra) # 80003784 <iunlock>
  end_op();
    8000573e:	fffff097          	auipc	ra,0xfffff
    80005742:	9c6080e7          	jalr	-1594(ra) # 80004104 <end_op>

  return fd;
    80005746:	854a                	mv	a0,s2
}
    80005748:	70ea                	ld	ra,184(sp)
    8000574a:	744a                	ld	s0,176(sp)
    8000574c:	74aa                	ld	s1,168(sp)
    8000574e:	790a                	ld	s2,160(sp)
    80005750:	69ea                	ld	s3,152(sp)
    80005752:	6129                	addi	sp,sp,192
    80005754:	8082                	ret
      end_op();
    80005756:	fffff097          	auipc	ra,0xfffff
    8000575a:	9ae080e7          	jalr	-1618(ra) # 80004104 <end_op>
      return -1;
    8000575e:	557d                	li	a0,-1
    80005760:	b7e5                	j	80005748 <sys_open+0xe4>
    if((ip = namei(path)) == 0){
    80005762:	f5040513          	addi	a0,s0,-176
    80005766:	ffffe097          	auipc	ra,0xffffe
    8000576a:	702080e7          	jalr	1794(ra) # 80003e68 <namei>
    8000576e:	84aa                	mv	s1,a0
    80005770:	c905                	beqz	a0,800057a0 <sys_open+0x13c>
    ilock(ip);
    80005772:	ffffe097          	auipc	ra,0xffffe
    80005776:	f50080e7          	jalr	-176(ra) # 800036c2 <ilock>
    if(ip->type == T_DIR && omode != O_RDONLY){
    8000577a:	04449703          	lh	a4,68(s1)
    8000577e:	4785                	li	a5,1
    80005780:	f4f711e3          	bne	a4,a5,800056c2 <sys_open+0x5e>
    80005784:	f4c42783          	lw	a5,-180(s0)
    80005788:	d7b9                	beqz	a5,800056d6 <sys_open+0x72>
      iunlockput(ip);
    8000578a:	8526                	mv	a0,s1
    8000578c:	ffffe097          	auipc	ra,0xffffe
    80005790:	198080e7          	jalr	408(ra) # 80003924 <iunlockput>
      end_op();
    80005794:	fffff097          	auipc	ra,0xfffff
    80005798:	970080e7          	jalr	-1680(ra) # 80004104 <end_op>
      return -1;
    8000579c:	557d                	li	a0,-1
    8000579e:	b76d                	j	80005748 <sys_open+0xe4>
      end_op();
    800057a0:	fffff097          	auipc	ra,0xfffff
    800057a4:	964080e7          	jalr	-1692(ra) # 80004104 <end_op>
      return -1;
    800057a8:	557d                	li	a0,-1
    800057aa:	bf79                	j	80005748 <sys_open+0xe4>
    iunlockput(ip);
    800057ac:	8526                	mv	a0,s1
    800057ae:	ffffe097          	auipc	ra,0xffffe
    800057b2:	176080e7          	jalr	374(ra) # 80003924 <iunlockput>
    end_op();
    800057b6:	fffff097          	auipc	ra,0xfffff
    800057ba:	94e080e7          	jalr	-1714(ra) # 80004104 <end_op>
    return -1;
    800057be:	557d                	li	a0,-1
    800057c0:	b761                	j	80005748 <sys_open+0xe4>
    f->type = FD_DEVICE;
    800057c2:	00f9a023          	sw	a5,0(s3)
    f->major = ip->major;
    800057c6:	04649783          	lh	a5,70(s1)
    800057ca:	02f99223          	sh	a5,36(s3)
    800057ce:	bf25                	j	80005706 <sys_open+0xa2>
    itrunc(ip);
    800057d0:	8526                	mv	a0,s1
    800057d2:	ffffe097          	auipc	ra,0xffffe
    800057d6:	ffe080e7          	jalr	-2(ra) # 800037d0 <itrunc>
    800057da:	bfa9                	j	80005734 <sys_open+0xd0>
      fileclose(f);
    800057dc:	854e                	mv	a0,s3
    800057de:	fffff097          	auipc	ra,0xfffff
    800057e2:	d72080e7          	jalr	-654(ra) # 80004550 <fileclose>
    iunlockput(ip);
    800057e6:	8526                	mv	a0,s1
    800057e8:	ffffe097          	auipc	ra,0xffffe
    800057ec:	13c080e7          	jalr	316(ra) # 80003924 <iunlockput>
    end_op();
    800057f0:	fffff097          	auipc	ra,0xfffff
    800057f4:	914080e7          	jalr	-1772(ra) # 80004104 <end_op>
    return -1;
    800057f8:	557d                	li	a0,-1
    800057fa:	b7b9                	j	80005748 <sys_open+0xe4>

00000000800057fc <sys_mkdir>:

uint64
sys_mkdir(void)
{
    800057fc:	7175                	addi	sp,sp,-144
    800057fe:	e506                	sd	ra,136(sp)
    80005800:	e122                	sd	s0,128(sp)
    80005802:	0900                	addi	s0,sp,144
  char path[MAXPATH];
  struct inode *ip;

  begin_op();
    80005804:	fffff097          	auipc	ra,0xfffff
    80005808:	880080e7          	jalr	-1920(ra) # 80004084 <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = create(path, T_DIR, 0, 0)) == 0){
    8000580c:	08000613          	li	a2,128
    80005810:	f7040593          	addi	a1,s0,-144
    80005814:	4501                	li	a0,0
    80005816:	ffffd097          	auipc	ra,0xffffd
    8000581a:	368080e7          	jalr	872(ra) # 80002b7e <argstr>
    8000581e:	02054963          	bltz	a0,80005850 <sys_mkdir+0x54>
    80005822:	4681                	li	a3,0
    80005824:	4601                	li	a2,0
    80005826:	4585                	li	a1,1
    80005828:	f7040513          	addi	a0,s0,-144
    8000582c:	00000097          	auipc	ra,0x0
    80005830:	800080e7          	jalr	-2048(ra) # 8000502c <create>
    80005834:	cd11                	beqz	a0,80005850 <sys_mkdir+0x54>
    end_op();
    return -1;
  }
  iunlockput(ip);
    80005836:	ffffe097          	auipc	ra,0xffffe
    8000583a:	0ee080e7          	jalr	238(ra) # 80003924 <iunlockput>
  end_op();
    8000583e:	fffff097          	auipc	ra,0xfffff
    80005842:	8c6080e7          	jalr	-1850(ra) # 80004104 <end_op>
  return 0;
    80005846:	4501                	li	a0,0
}
    80005848:	60aa                	ld	ra,136(sp)
    8000584a:	640a                	ld	s0,128(sp)
    8000584c:	6149                	addi	sp,sp,144
    8000584e:	8082                	ret
    end_op();
    80005850:	fffff097          	auipc	ra,0xfffff
    80005854:	8b4080e7          	jalr	-1868(ra) # 80004104 <end_op>
    return -1;
    80005858:	557d                	li	a0,-1
    8000585a:	b7fd                	j	80005848 <sys_mkdir+0x4c>

000000008000585c <sys_mknod>:

uint64
sys_mknod(void)
{
    8000585c:	7135                	addi	sp,sp,-160
    8000585e:	ed06                	sd	ra,152(sp)
    80005860:	e922                	sd	s0,144(sp)
    80005862:	1100                	addi	s0,sp,160
  struct inode *ip;
  char path[MAXPATH];
  int major, minor;

  begin_op();
    80005864:	fffff097          	auipc	ra,0xfffff
    80005868:	820080e7          	jalr	-2016(ra) # 80004084 <begin_op>
  argint(1, &major);
    8000586c:	f6c40593          	addi	a1,s0,-148
    80005870:	4505                	li	a0,1
    80005872:	ffffd097          	auipc	ra,0xffffd
    80005876:	2cc080e7          	jalr	716(ra) # 80002b3e <argint>
  argint(2, &minor);
    8000587a:	f6840593          	addi	a1,s0,-152
    8000587e:	4509                	li	a0,2
    80005880:	ffffd097          	auipc	ra,0xffffd
    80005884:	2be080e7          	jalr	702(ra) # 80002b3e <argint>
  if((argstr(0, path, MAXPATH)) < 0 ||
    80005888:	08000613          	li	a2,128
    8000588c:	f7040593          	addi	a1,s0,-144
    80005890:	4501                	li	a0,0
    80005892:	ffffd097          	auipc	ra,0xffffd
    80005896:	2ec080e7          	jalr	748(ra) # 80002b7e <argstr>
    8000589a:	02054b63          	bltz	a0,800058d0 <sys_mknod+0x74>
     (ip = create(path, T_DEVICE, major, minor)) == 0){
    8000589e:	f6841683          	lh	a3,-152(s0)
    800058a2:	f6c41603          	lh	a2,-148(s0)
    800058a6:	458d                	li	a1,3
    800058a8:	f7040513          	addi	a0,s0,-144
    800058ac:	fffff097          	auipc	ra,0xfffff
    800058b0:	780080e7          	jalr	1920(ra) # 8000502c <create>
  if((argstr(0, path, MAXPATH)) < 0 ||
    800058b4:	cd11                	beqz	a0,800058d0 <sys_mknod+0x74>
    end_op();
    return -1;
  }
  iunlockput(ip);
    800058b6:	ffffe097          	auipc	ra,0xffffe
    800058ba:	06e080e7          	jalr	110(ra) # 80003924 <iunlockput>
  end_op();
    800058be:	fffff097          	auipc	ra,0xfffff
    800058c2:	846080e7          	jalr	-1978(ra) # 80004104 <end_op>
  return 0;
    800058c6:	4501                	li	a0,0
}
    800058c8:	60ea                	ld	ra,152(sp)
    800058ca:	644a                	ld	s0,144(sp)
    800058cc:	610d                	addi	sp,sp,160
    800058ce:	8082                	ret
    end_op();
    800058d0:	fffff097          	auipc	ra,0xfffff
    800058d4:	834080e7          	jalr	-1996(ra) # 80004104 <end_op>
    return -1;
    800058d8:	557d                	li	a0,-1
    800058da:	b7fd                	j	800058c8 <sys_mknod+0x6c>

00000000800058dc <sys_chdir>:

uint64
sys_chdir(void)
{
    800058dc:	7135                	addi	sp,sp,-160
    800058de:	ed06                	sd	ra,152(sp)
    800058e0:	e922                	sd	s0,144(sp)
    800058e2:	e526                	sd	s1,136(sp)
    800058e4:	e14a                	sd	s2,128(sp)
    800058e6:	1100                	addi	s0,sp,160
  char path[MAXPATH];
  struct inode *ip;
  struct proc *p = myproc();
    800058e8:	ffffc097          	auipc	ra,0xffffc
    800058ec:	142080e7          	jalr	322(ra) # 80001a2a <myproc>
    800058f0:	892a                	mv	s2,a0
  
  begin_op();
    800058f2:	ffffe097          	auipc	ra,0xffffe
    800058f6:	792080e7          	jalr	1938(ra) # 80004084 <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = namei(path)) == 0){
    800058fa:	08000613          	li	a2,128
    800058fe:	f6040593          	addi	a1,s0,-160
    80005902:	4501                	li	a0,0
    80005904:	ffffd097          	auipc	ra,0xffffd
    80005908:	27a080e7          	jalr	634(ra) # 80002b7e <argstr>
    8000590c:	04054b63          	bltz	a0,80005962 <sys_chdir+0x86>
    80005910:	f6040513          	addi	a0,s0,-160
    80005914:	ffffe097          	auipc	ra,0xffffe
    80005918:	554080e7          	jalr	1364(ra) # 80003e68 <namei>
    8000591c:	84aa                	mv	s1,a0
    8000591e:	c131                	beqz	a0,80005962 <sys_chdir+0x86>
    end_op();
    return -1;
  }
  ilock(ip);
    80005920:	ffffe097          	auipc	ra,0xffffe
    80005924:	da2080e7          	jalr	-606(ra) # 800036c2 <ilock>
  if(ip->type != T_DIR){
    80005928:	04449703          	lh	a4,68(s1)
    8000592c:	4785                	li	a5,1
    8000592e:	04f71063          	bne	a4,a5,8000596e <sys_chdir+0x92>
    iunlockput(ip);
    end_op();
    return -1;
  }
  iunlock(ip);
    80005932:	8526                	mv	a0,s1
    80005934:	ffffe097          	auipc	ra,0xffffe
    80005938:	e50080e7          	jalr	-432(ra) # 80003784 <iunlock>
  iput(p->cwd);
    8000593c:	15093503          	ld	a0,336(s2)
    80005940:	ffffe097          	auipc	ra,0xffffe
    80005944:	f3c080e7          	jalr	-196(ra) # 8000387c <iput>
  end_op();
    80005948:	ffffe097          	auipc	ra,0xffffe
    8000594c:	7bc080e7          	jalr	1980(ra) # 80004104 <end_op>
  p->cwd = ip;
    80005950:	14993823          	sd	s1,336(s2)
  return 0;
    80005954:	4501                	li	a0,0
}
    80005956:	60ea                	ld	ra,152(sp)
    80005958:	644a                	ld	s0,144(sp)
    8000595a:	64aa                	ld	s1,136(sp)
    8000595c:	690a                	ld	s2,128(sp)
    8000595e:	610d                	addi	sp,sp,160
    80005960:	8082                	ret
    end_op();
    80005962:	ffffe097          	auipc	ra,0xffffe
    80005966:	7a2080e7          	jalr	1954(ra) # 80004104 <end_op>
    return -1;
    8000596a:	557d                	li	a0,-1
    8000596c:	b7ed                	j	80005956 <sys_chdir+0x7a>
    iunlockput(ip);
    8000596e:	8526                	mv	a0,s1
    80005970:	ffffe097          	auipc	ra,0xffffe
    80005974:	fb4080e7          	jalr	-76(ra) # 80003924 <iunlockput>
    end_op();
    80005978:	ffffe097          	auipc	ra,0xffffe
    8000597c:	78c080e7          	jalr	1932(ra) # 80004104 <end_op>
    return -1;
    80005980:	557d                	li	a0,-1
    80005982:	bfd1                	j	80005956 <sys_chdir+0x7a>

0000000080005984 <sys_exec>:

uint64
sys_exec(void)
{
    80005984:	7145                	addi	sp,sp,-464
    80005986:	e786                	sd	ra,456(sp)
    80005988:	e3a2                	sd	s0,448(sp)
    8000598a:	ff26                	sd	s1,440(sp)
    8000598c:	fb4a                	sd	s2,432(sp)
    8000598e:	f74e                	sd	s3,424(sp)
    80005990:	f352                	sd	s4,416(sp)
    80005992:	ef56                	sd	s5,408(sp)
    80005994:	0b80                	addi	s0,sp,464
  char path[MAXPATH], *argv[MAXARG];
  int i;
  uint64 uargv, uarg;

  argaddr(1, &uargv);
    80005996:	e3840593          	addi	a1,s0,-456
    8000599a:	4505                	li	a0,1
    8000599c:	ffffd097          	auipc	ra,0xffffd
    800059a0:	1c2080e7          	jalr	450(ra) # 80002b5e <argaddr>
  if(argstr(0, path, MAXPATH) < 0) {
    800059a4:	08000613          	li	a2,128
    800059a8:	f4040593          	addi	a1,s0,-192
    800059ac:	4501                	li	a0,0
    800059ae:	ffffd097          	auipc	ra,0xffffd
    800059b2:	1d0080e7          	jalr	464(ra) # 80002b7e <argstr>
    800059b6:	87aa                	mv	a5,a0
    return -1;
    800059b8:	557d                	li	a0,-1
  if(argstr(0, path, MAXPATH) < 0) {
    800059ba:	0c07c263          	bltz	a5,80005a7e <sys_exec+0xfa>
  }
  memset(argv, 0, sizeof(argv));
    800059be:	10000613          	li	a2,256
    800059c2:	4581                	li	a1,0
    800059c4:	e4040513          	addi	a0,s0,-448
    800059c8:	ffffb097          	auipc	ra,0xffffb
    800059cc:	36e080e7          	jalr	878(ra) # 80000d36 <memset>
  for(i=0;; i++){
    if(i >= NELEM(argv)){
    800059d0:	e4040493          	addi	s1,s0,-448
  memset(argv, 0, sizeof(argv));
    800059d4:	89a6                	mv	s3,s1
    800059d6:	4901                	li	s2,0
    if(i >= NELEM(argv)){
    800059d8:	02000a13          	li	s4,32
    800059dc:	00090a9b          	sext.w	s5,s2
      goto bad;
    }
    if(fetchaddr(uargv+sizeof(uint64)*i, (uint64*)&uarg) < 0){
    800059e0:	00391793          	slli	a5,s2,0x3
    800059e4:	e3040593          	addi	a1,s0,-464
    800059e8:	e3843503          	ld	a0,-456(s0)
    800059ec:	953e                	add	a0,a0,a5
    800059ee:	ffffd097          	auipc	ra,0xffffd
    800059f2:	0b2080e7          	jalr	178(ra) # 80002aa0 <fetchaddr>
    800059f6:	02054a63          	bltz	a0,80005a2a <sys_exec+0xa6>
      goto bad;
    }
    if(uarg == 0){
    800059fa:	e3043783          	ld	a5,-464(s0)
    800059fe:	c3b9                	beqz	a5,80005a44 <sys_exec+0xc0>
      argv[i] = 0;
      break;
    }
    argv[i] = kalloc();
    80005a00:	ffffb097          	auipc	ra,0xffffb
    80005a04:	0e6080e7          	jalr	230(ra) # 80000ae6 <kalloc>
    80005a08:	85aa                	mv	a1,a0
    80005a0a:	00a9b023          	sd	a0,0(s3)
    if(argv[i] == 0)
    80005a0e:	cd11                	beqz	a0,80005a2a <sys_exec+0xa6>
      goto bad;
    if(fetchstr(uarg, argv[i], PGSIZE) < 0)
    80005a10:	6605                	lui	a2,0x1
    80005a12:	e3043503          	ld	a0,-464(s0)
    80005a16:	ffffd097          	auipc	ra,0xffffd
    80005a1a:	0dc080e7          	jalr	220(ra) # 80002af2 <fetchstr>
    80005a1e:	00054663          	bltz	a0,80005a2a <sys_exec+0xa6>
    if(i >= NELEM(argv)){
    80005a22:	0905                	addi	s2,s2,1
    80005a24:	09a1                	addi	s3,s3,8
    80005a26:	fb491be3          	bne	s2,s4,800059dc <sys_exec+0x58>
    kfree(argv[i]);

  return ret;

 bad:
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005a2a:	10048913          	addi	s2,s1,256
    80005a2e:	6088                	ld	a0,0(s1)
    80005a30:	c531                	beqz	a0,80005a7c <sys_exec+0xf8>
    kfree(argv[i]);
    80005a32:	ffffb097          	auipc	ra,0xffffb
    80005a36:	fb8080e7          	jalr	-72(ra) # 800009ea <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005a3a:	04a1                	addi	s1,s1,8
    80005a3c:	ff2499e3          	bne	s1,s2,80005a2e <sys_exec+0xaa>
  return -1;
    80005a40:	557d                	li	a0,-1
    80005a42:	a835                	j	80005a7e <sys_exec+0xfa>
      argv[i] = 0;
    80005a44:	0a8e                	slli	s5,s5,0x3
    80005a46:	fc040793          	addi	a5,s0,-64
    80005a4a:	9abe                	add	s5,s5,a5
    80005a4c:	e80ab023          	sd	zero,-384(s5)
  int ret = exec(path, argv);
    80005a50:	e4040593          	addi	a1,s0,-448
    80005a54:	f4040513          	addi	a0,s0,-192
    80005a58:	fffff097          	auipc	ra,0xfffff
    80005a5c:	172080e7          	jalr	370(ra) # 80004bca <exec>
    80005a60:	892a                	mv	s2,a0
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005a62:	10048993          	addi	s3,s1,256
    80005a66:	6088                	ld	a0,0(s1)
    80005a68:	c901                	beqz	a0,80005a78 <sys_exec+0xf4>
    kfree(argv[i]);
    80005a6a:	ffffb097          	auipc	ra,0xffffb
    80005a6e:	f80080e7          	jalr	-128(ra) # 800009ea <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005a72:	04a1                	addi	s1,s1,8
    80005a74:	ff3499e3          	bne	s1,s3,80005a66 <sys_exec+0xe2>
  return ret;
    80005a78:	854a                	mv	a0,s2
    80005a7a:	a011                	j	80005a7e <sys_exec+0xfa>
  return -1;
    80005a7c:	557d                	li	a0,-1
}
    80005a7e:	60be                	ld	ra,456(sp)
    80005a80:	641e                	ld	s0,448(sp)
    80005a82:	74fa                	ld	s1,440(sp)
    80005a84:	795a                	ld	s2,432(sp)
    80005a86:	79ba                	ld	s3,424(sp)
    80005a88:	7a1a                	ld	s4,416(sp)
    80005a8a:	6afa                	ld	s5,408(sp)
    80005a8c:	6179                	addi	sp,sp,464
    80005a8e:	8082                	ret

0000000080005a90 <sys_pipe>:

uint64
sys_pipe(void)
{
    80005a90:	7139                	addi	sp,sp,-64
    80005a92:	fc06                	sd	ra,56(sp)
    80005a94:	f822                	sd	s0,48(sp)
    80005a96:	f426                	sd	s1,40(sp)
    80005a98:	0080                	addi	s0,sp,64
  uint64 fdarray; // user pointer to array of two integers
  struct file *rf, *wf;
  int fd0, fd1;
  struct proc *p = myproc();
    80005a9a:	ffffc097          	auipc	ra,0xffffc
    80005a9e:	f90080e7          	jalr	-112(ra) # 80001a2a <myproc>
    80005aa2:	84aa                	mv	s1,a0

  argaddr(0, &fdarray);
    80005aa4:	fd840593          	addi	a1,s0,-40
    80005aa8:	4501                	li	a0,0
    80005aaa:	ffffd097          	auipc	ra,0xffffd
    80005aae:	0b4080e7          	jalr	180(ra) # 80002b5e <argaddr>
  if(pipealloc(&rf, &wf) < 0)
    80005ab2:	fc840593          	addi	a1,s0,-56
    80005ab6:	fd040513          	addi	a0,s0,-48
    80005aba:	fffff097          	auipc	ra,0xfffff
    80005abe:	dc6080e7          	jalr	-570(ra) # 80004880 <pipealloc>
    return -1;
    80005ac2:	57fd                	li	a5,-1
  if(pipealloc(&rf, &wf) < 0)
    80005ac4:	0c054463          	bltz	a0,80005b8c <sys_pipe+0xfc>
  fd0 = -1;
    80005ac8:	fcf42223          	sw	a5,-60(s0)
  if((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0){
    80005acc:	fd043503          	ld	a0,-48(s0)
    80005ad0:	fffff097          	auipc	ra,0xfffff
    80005ad4:	51a080e7          	jalr	1306(ra) # 80004fea <fdalloc>
    80005ad8:	fca42223          	sw	a0,-60(s0)
    80005adc:	08054b63          	bltz	a0,80005b72 <sys_pipe+0xe2>
    80005ae0:	fc843503          	ld	a0,-56(s0)
    80005ae4:	fffff097          	auipc	ra,0xfffff
    80005ae8:	506080e7          	jalr	1286(ra) # 80004fea <fdalloc>
    80005aec:	fca42023          	sw	a0,-64(s0)
    80005af0:	06054863          	bltz	a0,80005b60 <sys_pipe+0xd0>
      p->ofile[fd0] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    80005af4:	4691                	li	a3,4
    80005af6:	fc440613          	addi	a2,s0,-60
    80005afa:	fd843583          	ld	a1,-40(s0)
    80005afe:	68a8                	ld	a0,80(s1)
    80005b00:	ffffc097          	auipc	ra,0xffffc
    80005b04:	be6080e7          	jalr	-1050(ra) # 800016e6 <copyout>
    80005b08:	02054063          	bltz	a0,80005b28 <sys_pipe+0x98>
     copyout(p->pagetable, fdarray+sizeof(fd0), (char *)&fd1, sizeof(fd1)) < 0){
    80005b0c:	4691                	li	a3,4
    80005b0e:	fc040613          	addi	a2,s0,-64
    80005b12:	fd843583          	ld	a1,-40(s0)
    80005b16:	0591                	addi	a1,a1,4
    80005b18:	68a8                	ld	a0,80(s1)
    80005b1a:	ffffc097          	auipc	ra,0xffffc
    80005b1e:	bcc080e7          	jalr	-1076(ra) # 800016e6 <copyout>
    p->ofile[fd1] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  return 0;
    80005b22:	4781                	li	a5,0
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    80005b24:	06055463          	bgez	a0,80005b8c <sys_pipe+0xfc>
    p->ofile[fd0] = 0;
    80005b28:	fc442783          	lw	a5,-60(s0)
    80005b2c:	07e9                	addi	a5,a5,26
    80005b2e:	078e                	slli	a5,a5,0x3
    80005b30:	97a6                	add	a5,a5,s1
    80005b32:	0007b023          	sd	zero,0(a5)
    p->ofile[fd1] = 0;
    80005b36:	fc042503          	lw	a0,-64(s0)
    80005b3a:	0569                	addi	a0,a0,26
    80005b3c:	050e                	slli	a0,a0,0x3
    80005b3e:	94aa                	add	s1,s1,a0
    80005b40:	0004b023          	sd	zero,0(s1)
    fileclose(rf);
    80005b44:	fd043503          	ld	a0,-48(s0)
    80005b48:	fffff097          	auipc	ra,0xfffff
    80005b4c:	a08080e7          	jalr	-1528(ra) # 80004550 <fileclose>
    fileclose(wf);
    80005b50:	fc843503          	ld	a0,-56(s0)
    80005b54:	fffff097          	auipc	ra,0xfffff
    80005b58:	9fc080e7          	jalr	-1540(ra) # 80004550 <fileclose>
    return -1;
    80005b5c:	57fd                	li	a5,-1
    80005b5e:	a03d                	j	80005b8c <sys_pipe+0xfc>
    if(fd0 >= 0)
    80005b60:	fc442783          	lw	a5,-60(s0)
    80005b64:	0007c763          	bltz	a5,80005b72 <sys_pipe+0xe2>
      p->ofile[fd0] = 0;
    80005b68:	07e9                	addi	a5,a5,26
    80005b6a:	078e                	slli	a5,a5,0x3
    80005b6c:	94be                	add	s1,s1,a5
    80005b6e:	0004b023          	sd	zero,0(s1)
    fileclose(rf);
    80005b72:	fd043503          	ld	a0,-48(s0)
    80005b76:	fffff097          	auipc	ra,0xfffff
    80005b7a:	9da080e7          	jalr	-1574(ra) # 80004550 <fileclose>
    fileclose(wf);
    80005b7e:	fc843503          	ld	a0,-56(s0)
    80005b82:	fffff097          	auipc	ra,0xfffff
    80005b86:	9ce080e7          	jalr	-1586(ra) # 80004550 <fileclose>
    return -1;
    80005b8a:	57fd                	li	a5,-1
}
    80005b8c:	853e                	mv	a0,a5
    80005b8e:	70e2                	ld	ra,56(sp)
    80005b90:	7442                	ld	s0,48(sp)
    80005b92:	74a2                	ld	s1,40(sp)
    80005b94:	6121                	addi	sp,sp,64
    80005b96:	8082                	ret
	...

0000000080005ba0 <kernelvec>:
    80005ba0:	7111                	addi	sp,sp,-256
    80005ba2:	e006                	sd	ra,0(sp)
    80005ba4:	e40a                	sd	sp,8(sp)
    80005ba6:	e80e                	sd	gp,16(sp)
    80005ba8:	ec12                	sd	tp,24(sp)
    80005baa:	f016                	sd	t0,32(sp)
    80005bac:	f41a                	sd	t1,40(sp)
    80005bae:	f81e                	sd	t2,48(sp)
    80005bb0:	fc22                	sd	s0,56(sp)
    80005bb2:	e0a6                	sd	s1,64(sp)
    80005bb4:	e4aa                	sd	a0,72(sp)
    80005bb6:	e8ae                	sd	a1,80(sp)
    80005bb8:	ecb2                	sd	a2,88(sp)
    80005bba:	f0b6                	sd	a3,96(sp)
    80005bbc:	f4ba                	sd	a4,104(sp)
    80005bbe:	f8be                	sd	a5,112(sp)
    80005bc0:	fcc2                	sd	a6,120(sp)
    80005bc2:	e146                	sd	a7,128(sp)
    80005bc4:	e54a                	sd	s2,136(sp)
    80005bc6:	e94e                	sd	s3,144(sp)
    80005bc8:	ed52                	sd	s4,152(sp)
    80005bca:	f156                	sd	s5,160(sp)
    80005bcc:	f55a                	sd	s6,168(sp)
    80005bce:	f95e                	sd	s7,176(sp)
    80005bd0:	fd62                	sd	s8,184(sp)
    80005bd2:	e1e6                	sd	s9,192(sp)
    80005bd4:	e5ea                	sd	s10,200(sp)
    80005bd6:	e9ee                	sd	s11,208(sp)
    80005bd8:	edf2                	sd	t3,216(sp)
    80005bda:	f1f6                	sd	t4,224(sp)
    80005bdc:	f5fa                	sd	t5,232(sp)
    80005bde:	f9fe                	sd	t6,240(sp)
    80005be0:	d8dfc0ef          	jal	ra,8000296c <kerneltrap>
    80005be4:	6082                	ld	ra,0(sp)
    80005be6:	6122                	ld	sp,8(sp)
    80005be8:	61c2                	ld	gp,16(sp)
    80005bea:	7282                	ld	t0,32(sp)
    80005bec:	7322                	ld	t1,40(sp)
    80005bee:	73c2                	ld	t2,48(sp)
    80005bf0:	7462                	ld	s0,56(sp)
    80005bf2:	6486                	ld	s1,64(sp)
    80005bf4:	6526                	ld	a0,72(sp)
    80005bf6:	65c6                	ld	a1,80(sp)
    80005bf8:	6666                	ld	a2,88(sp)
    80005bfa:	7686                	ld	a3,96(sp)
    80005bfc:	7726                	ld	a4,104(sp)
    80005bfe:	77c6                	ld	a5,112(sp)
    80005c00:	7866                	ld	a6,120(sp)
    80005c02:	688a                	ld	a7,128(sp)
    80005c04:	692a                	ld	s2,136(sp)
    80005c06:	69ca                	ld	s3,144(sp)
    80005c08:	6a6a                	ld	s4,152(sp)
    80005c0a:	7a8a                	ld	s5,160(sp)
    80005c0c:	7b2a                	ld	s6,168(sp)
    80005c0e:	7bca                	ld	s7,176(sp)
    80005c10:	7c6a                	ld	s8,184(sp)
    80005c12:	6c8e                	ld	s9,192(sp)
    80005c14:	6d2e                	ld	s10,200(sp)
    80005c16:	6dce                	ld	s11,208(sp)
    80005c18:	6e6e                	ld	t3,216(sp)
    80005c1a:	7e8e                	ld	t4,224(sp)
    80005c1c:	7f2e                	ld	t5,232(sp)
    80005c1e:	7fce                	ld	t6,240(sp)
    80005c20:	6111                	addi	sp,sp,256
    80005c22:	10200073          	sret
    80005c26:	00000013          	nop
    80005c2a:	00000013          	nop
    80005c2e:	0001                	nop

0000000080005c30 <timervec>:
    80005c30:	34051573          	csrrw	a0,mscratch,a0
    80005c34:	e10c                	sd	a1,0(a0)
    80005c36:	e510                	sd	a2,8(a0)
    80005c38:	e914                	sd	a3,16(a0)
    80005c3a:	6d0c                	ld	a1,24(a0)
    80005c3c:	7110                	ld	a2,32(a0)
    80005c3e:	6194                	ld	a3,0(a1)
    80005c40:	96b2                	add	a3,a3,a2
    80005c42:	e194                	sd	a3,0(a1)
    80005c44:	4589                	li	a1,2
    80005c46:	14459073          	csrw	sip,a1
    80005c4a:	6914                	ld	a3,16(a0)
    80005c4c:	6510                	ld	a2,8(a0)
    80005c4e:	610c                	ld	a1,0(a0)
    80005c50:	34051573          	csrrw	a0,mscratch,a0
    80005c54:	30200073          	mret
	...

0000000080005c5a <plicinit>:
// the riscv Platform Level Interrupt Controller (PLIC).
//

void
plicinit(void)
{
    80005c5a:	1141                	addi	sp,sp,-16
    80005c5c:	e422                	sd	s0,8(sp)
    80005c5e:	0800                	addi	s0,sp,16
  // set desired IRQ priorities non-zero (otherwise disabled).
  *(uint32*)(PLIC + UART0_IRQ*4) = 1;
    80005c60:	0c0007b7          	lui	a5,0xc000
    80005c64:	4705                	li	a4,1
    80005c66:	d798                	sw	a4,40(a5)
  *(uint32*)(PLIC + VIRTIO0_IRQ*4) = 1;
    80005c68:	c3d8                	sw	a4,4(a5)
}
    80005c6a:	6422                	ld	s0,8(sp)
    80005c6c:	0141                	addi	sp,sp,16
    80005c6e:	8082                	ret

0000000080005c70 <plicinithart>:

void
plicinithart(void)
{
    80005c70:	1141                	addi	sp,sp,-16
    80005c72:	e406                	sd	ra,8(sp)
    80005c74:	e022                	sd	s0,0(sp)
    80005c76:	0800                	addi	s0,sp,16
  int hart = cpuid();
    80005c78:	ffffc097          	auipc	ra,0xffffc
    80005c7c:	d86080e7          	jalr	-634(ra) # 800019fe <cpuid>
  
  // set enable bits for this hart's S-mode
  // for the uart and virtio disk.
  *(uint32*)PLIC_SENABLE(hart) = (1 << UART0_IRQ) | (1 << VIRTIO0_IRQ);
    80005c80:	0085171b          	slliw	a4,a0,0x8
    80005c84:	0c0027b7          	lui	a5,0xc002
    80005c88:	97ba                	add	a5,a5,a4
    80005c8a:	40200713          	li	a4,1026
    80005c8e:	08e7a023          	sw	a4,128(a5) # c002080 <_entry-0x73ffdf80>

  // set this hart's S-mode priority threshold to 0.
  *(uint32*)PLIC_SPRIORITY(hart) = 0;
    80005c92:	00d5151b          	slliw	a0,a0,0xd
    80005c96:	0c2017b7          	lui	a5,0xc201
    80005c9a:	953e                	add	a0,a0,a5
    80005c9c:	00052023          	sw	zero,0(a0)
}
    80005ca0:	60a2                	ld	ra,8(sp)
    80005ca2:	6402                	ld	s0,0(sp)
    80005ca4:	0141                	addi	sp,sp,16
    80005ca6:	8082                	ret

0000000080005ca8 <plic_claim>:

// ask the PLIC what interrupt we should serve.
int
plic_claim(void)
{
    80005ca8:	1141                	addi	sp,sp,-16
    80005caa:	e406                	sd	ra,8(sp)
    80005cac:	e022                	sd	s0,0(sp)
    80005cae:	0800                	addi	s0,sp,16
  int hart = cpuid();
    80005cb0:	ffffc097          	auipc	ra,0xffffc
    80005cb4:	d4e080e7          	jalr	-690(ra) # 800019fe <cpuid>
  int irq = *(uint32*)PLIC_SCLAIM(hart);
    80005cb8:	00d5179b          	slliw	a5,a0,0xd
    80005cbc:	0c201537          	lui	a0,0xc201
    80005cc0:	953e                	add	a0,a0,a5
  return irq;
}
    80005cc2:	4148                	lw	a0,4(a0)
    80005cc4:	60a2                	ld	ra,8(sp)
    80005cc6:	6402                	ld	s0,0(sp)
    80005cc8:	0141                	addi	sp,sp,16
    80005cca:	8082                	ret

0000000080005ccc <plic_complete>:

// tell the PLIC we've served this IRQ.
void
plic_complete(int irq)
{
    80005ccc:	1101                	addi	sp,sp,-32
    80005cce:	ec06                	sd	ra,24(sp)
    80005cd0:	e822                	sd	s0,16(sp)
    80005cd2:	e426                	sd	s1,8(sp)
    80005cd4:	1000                	addi	s0,sp,32
    80005cd6:	84aa                	mv	s1,a0
  int hart = cpuid();
    80005cd8:	ffffc097          	auipc	ra,0xffffc
    80005cdc:	d26080e7          	jalr	-730(ra) # 800019fe <cpuid>
  *(uint32*)PLIC_SCLAIM(hart) = irq;
    80005ce0:	00d5151b          	slliw	a0,a0,0xd
    80005ce4:	0c2017b7          	lui	a5,0xc201
    80005ce8:	97aa                	add	a5,a5,a0
    80005cea:	c3c4                	sw	s1,4(a5)
}
    80005cec:	60e2                	ld	ra,24(sp)
    80005cee:	6442                	ld	s0,16(sp)
    80005cf0:	64a2                	ld	s1,8(sp)
    80005cf2:	6105                	addi	sp,sp,32
    80005cf4:	8082                	ret

0000000080005cf6 <free_desc>:
}

// mark a descriptor as free.
static void
free_desc(int i)
{
    80005cf6:	1141                	addi	sp,sp,-16
    80005cf8:	e406                	sd	ra,8(sp)
    80005cfa:	e022                	sd	s0,0(sp)
    80005cfc:	0800                	addi	s0,sp,16
  if(i >= NUM)
    80005cfe:	479d                	li	a5,7
    80005d00:	04a7cc63          	blt	a5,a0,80005d58 <free_desc+0x62>
    panic("free_desc 1");
  if(disk.free[i])
    80005d04:	0001c797          	auipc	a5,0x1c
    80005d08:	f3c78793          	addi	a5,a5,-196 # 80021c40 <disk>
    80005d0c:	97aa                	add	a5,a5,a0
    80005d0e:	0187c783          	lbu	a5,24(a5)
    80005d12:	ebb9                	bnez	a5,80005d68 <free_desc+0x72>
    panic("free_desc 2");
  disk.desc[i].addr = 0;
    80005d14:	00451613          	slli	a2,a0,0x4
    80005d18:	0001c797          	auipc	a5,0x1c
    80005d1c:	f2878793          	addi	a5,a5,-216 # 80021c40 <disk>
    80005d20:	6394                	ld	a3,0(a5)
    80005d22:	96b2                	add	a3,a3,a2
    80005d24:	0006b023          	sd	zero,0(a3)
  disk.desc[i].len = 0;
    80005d28:	6398                	ld	a4,0(a5)
    80005d2a:	9732                	add	a4,a4,a2
    80005d2c:	00072423          	sw	zero,8(a4)
  disk.desc[i].flags = 0;
    80005d30:	00071623          	sh	zero,12(a4)
  disk.desc[i].next = 0;
    80005d34:	00071723          	sh	zero,14(a4)
  disk.free[i] = 1;
    80005d38:	953e                	add	a0,a0,a5
    80005d3a:	4785                	li	a5,1
    80005d3c:	00f50c23          	sb	a5,24(a0) # c201018 <_entry-0x73dfefe8>
  wakeup(&disk.free[0]);
    80005d40:	0001c517          	auipc	a0,0x1c
    80005d44:	f1850513          	addi	a0,a0,-232 # 80021c58 <disk+0x18>
    80005d48:	ffffc097          	auipc	ra,0xffffc
    80005d4c:	3ee080e7          	jalr	1006(ra) # 80002136 <wakeup>
}
    80005d50:	60a2                	ld	ra,8(sp)
    80005d52:	6402                	ld	s0,0(sp)
    80005d54:	0141                	addi	sp,sp,16
    80005d56:	8082                	ret
    panic("free_desc 1");
    80005d58:	00003517          	auipc	a0,0x3
    80005d5c:	a2850513          	addi	a0,a0,-1496 # 80008780 <syscalls+0x2f8>
    80005d60:	ffffa097          	auipc	ra,0xffffa
    80005d64:	7de080e7          	jalr	2014(ra) # 8000053e <panic>
    panic("free_desc 2");
    80005d68:	00003517          	auipc	a0,0x3
    80005d6c:	a2850513          	addi	a0,a0,-1496 # 80008790 <syscalls+0x308>
    80005d70:	ffffa097          	auipc	ra,0xffffa
    80005d74:	7ce080e7          	jalr	1998(ra) # 8000053e <panic>

0000000080005d78 <virtio_disk_init>:
{
    80005d78:	1101                	addi	sp,sp,-32
    80005d7a:	ec06                	sd	ra,24(sp)
    80005d7c:	e822                	sd	s0,16(sp)
    80005d7e:	e426                	sd	s1,8(sp)
    80005d80:	e04a                	sd	s2,0(sp)
    80005d82:	1000                	addi	s0,sp,32
  initlock(&disk.vdisk_lock, "virtio_disk");
    80005d84:	00003597          	auipc	a1,0x3
    80005d88:	a1c58593          	addi	a1,a1,-1508 # 800087a0 <syscalls+0x318>
    80005d8c:	0001c517          	auipc	a0,0x1c
    80005d90:	fdc50513          	addi	a0,a0,-36 # 80021d68 <disk+0x128>
    80005d94:	ffffb097          	auipc	ra,0xffffb
    80005d98:	e16080e7          	jalr	-490(ra) # 80000baa <initlock>
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    80005d9c:	100017b7          	lui	a5,0x10001
    80005da0:	4398                	lw	a4,0(a5)
    80005da2:	2701                	sext.w	a4,a4
    80005da4:	747277b7          	lui	a5,0x74727
    80005da8:	97678793          	addi	a5,a5,-1674 # 74726976 <_entry-0xb8d968a>
    80005dac:	14f71c63          	bne	a4,a5,80005f04 <virtio_disk_init+0x18c>
     *R(VIRTIO_MMIO_VERSION) != 2 ||
    80005db0:	100017b7          	lui	a5,0x10001
    80005db4:	43dc                	lw	a5,4(a5)
    80005db6:	2781                	sext.w	a5,a5
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    80005db8:	4709                	li	a4,2
    80005dba:	14e79563          	bne	a5,a4,80005f04 <virtio_disk_init+0x18c>
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    80005dbe:	100017b7          	lui	a5,0x10001
    80005dc2:	479c                	lw	a5,8(a5)
    80005dc4:	2781                	sext.w	a5,a5
     *R(VIRTIO_MMIO_VERSION) != 2 ||
    80005dc6:	12e79f63          	bne	a5,a4,80005f04 <virtio_disk_init+0x18c>
     *R(VIRTIO_MMIO_VENDOR_ID) != 0x554d4551){
    80005dca:	100017b7          	lui	a5,0x10001
    80005dce:	47d8                	lw	a4,12(a5)
    80005dd0:	2701                	sext.w	a4,a4
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    80005dd2:	554d47b7          	lui	a5,0x554d4
    80005dd6:	55178793          	addi	a5,a5,1361 # 554d4551 <_entry-0x2ab2baaf>
    80005dda:	12f71563          	bne	a4,a5,80005f04 <virtio_disk_init+0x18c>
  *R(VIRTIO_MMIO_STATUS) = status;
    80005dde:	100017b7          	lui	a5,0x10001
    80005de2:	0607a823          	sw	zero,112(a5) # 10001070 <_entry-0x6fffef90>
  *R(VIRTIO_MMIO_STATUS) = status;
    80005de6:	4705                	li	a4,1
    80005de8:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    80005dea:	470d                	li	a4,3
    80005dec:	dbb8                	sw	a4,112(a5)
  uint64 features = *R(VIRTIO_MMIO_DEVICE_FEATURES);
    80005dee:	4b94                	lw	a3,16(a5)
  features &= ~(1 << VIRTIO_RING_F_INDIRECT_DESC);
    80005df0:	c7ffe737          	lui	a4,0xc7ffe
    80005df4:	75f70713          	addi	a4,a4,1887 # ffffffffc7ffe75f <end+0xffffffff47fdc9df>
    80005df8:	8f75                	and	a4,a4,a3
  *R(VIRTIO_MMIO_DRIVER_FEATURES) = features;
    80005dfa:	2701                	sext.w	a4,a4
    80005dfc:	d398                	sw	a4,32(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    80005dfe:	472d                	li	a4,11
    80005e00:	dbb8                	sw	a4,112(a5)
  status = *R(VIRTIO_MMIO_STATUS);
    80005e02:	5bbc                	lw	a5,112(a5)
    80005e04:	0007891b          	sext.w	s2,a5
  if(!(status & VIRTIO_CONFIG_S_FEATURES_OK))
    80005e08:	8ba1                	andi	a5,a5,8
    80005e0a:	10078563          	beqz	a5,80005f14 <virtio_disk_init+0x19c>
  *R(VIRTIO_MMIO_QUEUE_SEL) = 0;
    80005e0e:	100017b7          	lui	a5,0x10001
    80005e12:	0207a823          	sw	zero,48(a5) # 10001030 <_entry-0x6fffefd0>
  if(*R(VIRTIO_MMIO_QUEUE_READY))
    80005e16:	43fc                	lw	a5,68(a5)
    80005e18:	2781                	sext.w	a5,a5
    80005e1a:	10079563          	bnez	a5,80005f24 <virtio_disk_init+0x1ac>
  uint32 max = *R(VIRTIO_MMIO_QUEUE_NUM_MAX);
    80005e1e:	100017b7          	lui	a5,0x10001
    80005e22:	5bdc                	lw	a5,52(a5)
    80005e24:	2781                	sext.w	a5,a5
  if(max == 0)
    80005e26:	10078763          	beqz	a5,80005f34 <virtio_disk_init+0x1bc>
  if(max < NUM)
    80005e2a:	471d                	li	a4,7
    80005e2c:	10f77c63          	bgeu	a4,a5,80005f44 <virtio_disk_init+0x1cc>
  disk.desc = kalloc();
    80005e30:	ffffb097          	auipc	ra,0xffffb
    80005e34:	cb6080e7          	jalr	-842(ra) # 80000ae6 <kalloc>
    80005e38:	0001c497          	auipc	s1,0x1c
    80005e3c:	e0848493          	addi	s1,s1,-504 # 80021c40 <disk>
    80005e40:	e088                	sd	a0,0(s1)
  disk.avail = kalloc();
    80005e42:	ffffb097          	auipc	ra,0xffffb
    80005e46:	ca4080e7          	jalr	-860(ra) # 80000ae6 <kalloc>
    80005e4a:	e488                	sd	a0,8(s1)
  disk.used = kalloc();
    80005e4c:	ffffb097          	auipc	ra,0xffffb
    80005e50:	c9a080e7          	jalr	-870(ra) # 80000ae6 <kalloc>
    80005e54:	87aa                	mv	a5,a0
    80005e56:	e888                	sd	a0,16(s1)
  if(!disk.desc || !disk.avail || !disk.used)
    80005e58:	6088                	ld	a0,0(s1)
    80005e5a:	cd6d                	beqz	a0,80005f54 <virtio_disk_init+0x1dc>
    80005e5c:	0001c717          	auipc	a4,0x1c
    80005e60:	dec73703          	ld	a4,-532(a4) # 80021c48 <disk+0x8>
    80005e64:	cb65                	beqz	a4,80005f54 <virtio_disk_init+0x1dc>
    80005e66:	c7fd                	beqz	a5,80005f54 <virtio_disk_init+0x1dc>
  memset(disk.desc, 0, PGSIZE);
    80005e68:	6605                	lui	a2,0x1
    80005e6a:	4581                	li	a1,0
    80005e6c:	ffffb097          	auipc	ra,0xffffb
    80005e70:	eca080e7          	jalr	-310(ra) # 80000d36 <memset>
  memset(disk.avail, 0, PGSIZE);
    80005e74:	0001c497          	auipc	s1,0x1c
    80005e78:	dcc48493          	addi	s1,s1,-564 # 80021c40 <disk>
    80005e7c:	6605                	lui	a2,0x1
    80005e7e:	4581                	li	a1,0
    80005e80:	6488                	ld	a0,8(s1)
    80005e82:	ffffb097          	auipc	ra,0xffffb
    80005e86:	eb4080e7          	jalr	-332(ra) # 80000d36 <memset>
  memset(disk.used, 0, PGSIZE);
    80005e8a:	6605                	lui	a2,0x1
    80005e8c:	4581                	li	a1,0
    80005e8e:	6888                	ld	a0,16(s1)
    80005e90:	ffffb097          	auipc	ra,0xffffb
    80005e94:	ea6080e7          	jalr	-346(ra) # 80000d36 <memset>
  *R(VIRTIO_MMIO_QUEUE_NUM) = NUM;
    80005e98:	100017b7          	lui	a5,0x10001
    80005e9c:	4721                	li	a4,8
    80005e9e:	df98                	sw	a4,56(a5)
  *R(VIRTIO_MMIO_QUEUE_DESC_LOW) = (uint64)disk.desc;
    80005ea0:	4098                	lw	a4,0(s1)
    80005ea2:	08e7a023          	sw	a4,128(a5) # 10001080 <_entry-0x6fffef80>
  *R(VIRTIO_MMIO_QUEUE_DESC_HIGH) = (uint64)disk.desc >> 32;
    80005ea6:	40d8                	lw	a4,4(s1)
    80005ea8:	08e7a223          	sw	a4,132(a5)
  *R(VIRTIO_MMIO_DRIVER_DESC_LOW) = (uint64)disk.avail;
    80005eac:	6498                	ld	a4,8(s1)
    80005eae:	0007069b          	sext.w	a3,a4
    80005eb2:	08d7a823          	sw	a3,144(a5)
  *R(VIRTIO_MMIO_DRIVER_DESC_HIGH) = (uint64)disk.avail >> 32;
    80005eb6:	9701                	srai	a4,a4,0x20
    80005eb8:	08e7aa23          	sw	a4,148(a5)
  *R(VIRTIO_MMIO_DEVICE_DESC_LOW) = (uint64)disk.used;
    80005ebc:	6898                	ld	a4,16(s1)
    80005ebe:	0007069b          	sext.w	a3,a4
    80005ec2:	0ad7a023          	sw	a3,160(a5)
  *R(VIRTIO_MMIO_DEVICE_DESC_HIGH) = (uint64)disk.used >> 32;
    80005ec6:	9701                	srai	a4,a4,0x20
    80005ec8:	0ae7a223          	sw	a4,164(a5)
  *R(VIRTIO_MMIO_QUEUE_READY) = 0x1;
    80005ecc:	4705                	li	a4,1
    80005ece:	c3f8                	sw	a4,68(a5)
    disk.free[i] = 1;
    80005ed0:	00e48c23          	sb	a4,24(s1)
    80005ed4:	00e48ca3          	sb	a4,25(s1)
    80005ed8:	00e48d23          	sb	a4,26(s1)
    80005edc:	00e48da3          	sb	a4,27(s1)
    80005ee0:	00e48e23          	sb	a4,28(s1)
    80005ee4:	00e48ea3          	sb	a4,29(s1)
    80005ee8:	00e48f23          	sb	a4,30(s1)
    80005eec:	00e48fa3          	sb	a4,31(s1)
  status |= VIRTIO_CONFIG_S_DRIVER_OK;
    80005ef0:	00496913          	ori	s2,s2,4
  *R(VIRTIO_MMIO_STATUS) = status;
    80005ef4:	0727a823          	sw	s2,112(a5)
}
    80005ef8:	60e2                	ld	ra,24(sp)
    80005efa:	6442                	ld	s0,16(sp)
    80005efc:	64a2                	ld	s1,8(sp)
    80005efe:	6902                	ld	s2,0(sp)
    80005f00:	6105                	addi	sp,sp,32
    80005f02:	8082                	ret
    panic("could not find virtio disk");
    80005f04:	00003517          	auipc	a0,0x3
    80005f08:	8ac50513          	addi	a0,a0,-1876 # 800087b0 <syscalls+0x328>
    80005f0c:	ffffa097          	auipc	ra,0xffffa
    80005f10:	632080e7          	jalr	1586(ra) # 8000053e <panic>
    panic("virtio disk FEATURES_OK unset");
    80005f14:	00003517          	auipc	a0,0x3
    80005f18:	8bc50513          	addi	a0,a0,-1860 # 800087d0 <syscalls+0x348>
    80005f1c:	ffffa097          	auipc	ra,0xffffa
    80005f20:	622080e7          	jalr	1570(ra) # 8000053e <panic>
    panic("virtio disk should not be ready");
    80005f24:	00003517          	auipc	a0,0x3
    80005f28:	8cc50513          	addi	a0,a0,-1844 # 800087f0 <syscalls+0x368>
    80005f2c:	ffffa097          	auipc	ra,0xffffa
    80005f30:	612080e7          	jalr	1554(ra) # 8000053e <panic>
    panic("virtio disk has no queue 0");
    80005f34:	00003517          	auipc	a0,0x3
    80005f38:	8dc50513          	addi	a0,a0,-1828 # 80008810 <syscalls+0x388>
    80005f3c:	ffffa097          	auipc	ra,0xffffa
    80005f40:	602080e7          	jalr	1538(ra) # 8000053e <panic>
    panic("virtio disk max queue too short");
    80005f44:	00003517          	auipc	a0,0x3
    80005f48:	8ec50513          	addi	a0,a0,-1812 # 80008830 <syscalls+0x3a8>
    80005f4c:	ffffa097          	auipc	ra,0xffffa
    80005f50:	5f2080e7          	jalr	1522(ra) # 8000053e <panic>
    panic("virtio disk kalloc");
    80005f54:	00003517          	auipc	a0,0x3
    80005f58:	8fc50513          	addi	a0,a0,-1796 # 80008850 <syscalls+0x3c8>
    80005f5c:	ffffa097          	auipc	ra,0xffffa
    80005f60:	5e2080e7          	jalr	1506(ra) # 8000053e <panic>

0000000080005f64 <virtio_disk_rw>:
  return 0;
}

void
virtio_disk_rw(struct buf *b, int write)
{
    80005f64:	7119                	addi	sp,sp,-128
    80005f66:	fc86                	sd	ra,120(sp)
    80005f68:	f8a2                	sd	s0,112(sp)
    80005f6a:	f4a6                	sd	s1,104(sp)
    80005f6c:	f0ca                	sd	s2,96(sp)
    80005f6e:	ecce                	sd	s3,88(sp)
    80005f70:	e8d2                	sd	s4,80(sp)
    80005f72:	e4d6                	sd	s5,72(sp)
    80005f74:	e0da                	sd	s6,64(sp)
    80005f76:	fc5e                	sd	s7,56(sp)
    80005f78:	f862                	sd	s8,48(sp)
    80005f7a:	f466                	sd	s9,40(sp)
    80005f7c:	f06a                	sd	s10,32(sp)
    80005f7e:	ec6e                	sd	s11,24(sp)
    80005f80:	0100                	addi	s0,sp,128
    80005f82:	8aaa                	mv	s5,a0
    80005f84:	8c2e                	mv	s8,a1
  uint64 sector = b->blockno * (BSIZE / 512);
    80005f86:	00c52d03          	lw	s10,12(a0)
    80005f8a:	001d1d1b          	slliw	s10,s10,0x1
    80005f8e:	1d02                	slli	s10,s10,0x20
    80005f90:	020d5d13          	srli	s10,s10,0x20

  acquire(&disk.vdisk_lock);
    80005f94:	0001c517          	auipc	a0,0x1c
    80005f98:	dd450513          	addi	a0,a0,-556 # 80021d68 <disk+0x128>
    80005f9c:	ffffb097          	auipc	ra,0xffffb
    80005fa0:	c9e080e7          	jalr	-866(ra) # 80000c3a <acquire>
  for(int i = 0; i < 3; i++){
    80005fa4:	4981                	li	s3,0
  for(int i = 0; i < NUM; i++){
    80005fa6:	44a1                	li	s1,8
      disk.free[i] = 0;
    80005fa8:	0001cb97          	auipc	s7,0x1c
    80005fac:	c98b8b93          	addi	s7,s7,-872 # 80021c40 <disk>
  for(int i = 0; i < 3; i++){
    80005fb0:	4b0d                	li	s6,3
  int idx[3];
  while(1){
    if(alloc3_desc(idx) == 0) {
      break;
    }
    sleep(&disk.free[0], &disk.vdisk_lock);
    80005fb2:	0001cc97          	auipc	s9,0x1c
    80005fb6:	db6c8c93          	addi	s9,s9,-586 # 80021d68 <disk+0x128>
    80005fba:	a08d                	j	8000601c <virtio_disk_rw+0xb8>
      disk.free[i] = 0;
    80005fbc:	00fb8733          	add	a4,s7,a5
    80005fc0:	00070c23          	sb	zero,24(a4)
    idx[i] = alloc_desc();
    80005fc4:	c19c                	sw	a5,0(a1)
    if(idx[i] < 0){
    80005fc6:	0207c563          	bltz	a5,80005ff0 <virtio_disk_rw+0x8c>
  for(int i = 0; i < 3; i++){
    80005fca:	2905                	addiw	s2,s2,1
    80005fcc:	0611                	addi	a2,a2,4
    80005fce:	05690c63          	beq	s2,s6,80006026 <virtio_disk_rw+0xc2>
    idx[i] = alloc_desc();
    80005fd2:	85b2                	mv	a1,a2
  for(int i = 0; i < NUM; i++){
    80005fd4:	0001c717          	auipc	a4,0x1c
    80005fd8:	c6c70713          	addi	a4,a4,-916 # 80021c40 <disk>
    80005fdc:	87ce                	mv	a5,s3
    if(disk.free[i]){
    80005fde:	01874683          	lbu	a3,24(a4)
    80005fe2:	fee9                	bnez	a3,80005fbc <virtio_disk_rw+0x58>
  for(int i = 0; i < NUM; i++){
    80005fe4:	2785                	addiw	a5,a5,1
    80005fe6:	0705                	addi	a4,a4,1
    80005fe8:	fe979be3          	bne	a5,s1,80005fde <virtio_disk_rw+0x7a>
    idx[i] = alloc_desc();
    80005fec:	57fd                	li	a5,-1
    80005fee:	c19c                	sw	a5,0(a1)
      for(int j = 0; j < i; j++)
    80005ff0:	01205d63          	blez	s2,8000600a <virtio_disk_rw+0xa6>
    80005ff4:	8dce                	mv	s11,s3
        free_desc(idx[j]);
    80005ff6:	000a2503          	lw	a0,0(s4)
    80005ffa:	00000097          	auipc	ra,0x0
    80005ffe:	cfc080e7          	jalr	-772(ra) # 80005cf6 <free_desc>
      for(int j = 0; j < i; j++)
    80006002:	2d85                	addiw	s11,s11,1
    80006004:	0a11                	addi	s4,s4,4
    80006006:	ffb918e3          	bne	s2,s11,80005ff6 <virtio_disk_rw+0x92>
    sleep(&disk.free[0], &disk.vdisk_lock);
    8000600a:	85e6                	mv	a1,s9
    8000600c:	0001c517          	auipc	a0,0x1c
    80006010:	c4c50513          	addi	a0,a0,-948 # 80021c58 <disk+0x18>
    80006014:	ffffc097          	auipc	ra,0xffffc
    80006018:	0be080e7          	jalr	190(ra) # 800020d2 <sleep>
  for(int i = 0; i < 3; i++){
    8000601c:	f8040a13          	addi	s4,s0,-128
{
    80006020:	8652                	mv	a2,s4
  for(int i = 0; i < 3; i++){
    80006022:	894e                	mv	s2,s3
    80006024:	b77d                	j	80005fd2 <virtio_disk_rw+0x6e>
  }

  // format the three descriptors.
  // qemu's virtio-blk.c reads them.

  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];
    80006026:	f8042583          	lw	a1,-128(s0)
    8000602a:	00a58793          	addi	a5,a1,10
    8000602e:	0792                	slli	a5,a5,0x4

  if(write)
    80006030:	0001c617          	auipc	a2,0x1c
    80006034:	c1060613          	addi	a2,a2,-1008 # 80021c40 <disk>
    80006038:	00f60733          	add	a4,a2,a5
    8000603c:	018036b3          	snez	a3,s8
    80006040:	c714                	sw	a3,8(a4)
    buf0->type = VIRTIO_BLK_T_OUT; // write the disk
  else
    buf0->type = VIRTIO_BLK_T_IN; // read the disk
  buf0->reserved = 0;
    80006042:	00072623          	sw	zero,12(a4)
  buf0->sector = sector;
    80006046:	01a73823          	sd	s10,16(a4)

  disk.desc[idx[0]].addr = (uint64) buf0;
    8000604a:	f6078693          	addi	a3,a5,-160
    8000604e:	6218                	ld	a4,0(a2)
    80006050:	9736                	add	a4,a4,a3
  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];
    80006052:	00878513          	addi	a0,a5,8
    80006056:	9532                	add	a0,a0,a2
  disk.desc[idx[0]].addr = (uint64) buf0;
    80006058:	e308                	sd	a0,0(a4)
  disk.desc[idx[0]].len = sizeof(struct virtio_blk_req);
    8000605a:	6208                	ld	a0,0(a2)
    8000605c:	96aa                	add	a3,a3,a0
    8000605e:	4741                	li	a4,16
    80006060:	c698                	sw	a4,8(a3)
  disk.desc[idx[0]].flags = VRING_DESC_F_NEXT;
    80006062:	4705                	li	a4,1
    80006064:	00e69623          	sh	a4,12(a3)
  disk.desc[idx[0]].next = idx[1];
    80006068:	f8442703          	lw	a4,-124(s0)
    8000606c:	00e69723          	sh	a4,14(a3)

  disk.desc[idx[1]].addr = (uint64) b->data;
    80006070:	0712                	slli	a4,a4,0x4
    80006072:	953a                	add	a0,a0,a4
    80006074:	058a8693          	addi	a3,s5,88
    80006078:	e114                	sd	a3,0(a0)
  disk.desc[idx[1]].len = BSIZE;
    8000607a:	6208                	ld	a0,0(a2)
    8000607c:	972a                	add	a4,a4,a0
    8000607e:	40000693          	li	a3,1024
    80006082:	c714                	sw	a3,8(a4)
  if(write)
    disk.desc[idx[1]].flags = 0; // device reads b->data
  else
    disk.desc[idx[1]].flags = VRING_DESC_F_WRITE; // device writes b->data
    80006084:	001c3c13          	seqz	s8,s8
    80006088:	0c06                	slli	s8,s8,0x1
  disk.desc[idx[1]].flags |= VRING_DESC_F_NEXT;
    8000608a:	001c6c13          	ori	s8,s8,1
    8000608e:	01871623          	sh	s8,12(a4)
  disk.desc[idx[1]].next = idx[2];
    80006092:	f8842603          	lw	a2,-120(s0)
    80006096:	00c71723          	sh	a2,14(a4)

  disk.info[idx[0]].status = 0xff; // device writes 0 on success
    8000609a:	0001c697          	auipc	a3,0x1c
    8000609e:	ba668693          	addi	a3,a3,-1114 # 80021c40 <disk>
    800060a2:	00258713          	addi	a4,a1,2
    800060a6:	0712                	slli	a4,a4,0x4
    800060a8:	9736                	add	a4,a4,a3
    800060aa:	587d                	li	a6,-1
    800060ac:	01070823          	sb	a6,16(a4)
  disk.desc[idx[2]].addr = (uint64) &disk.info[idx[0]].status;
    800060b0:	0612                	slli	a2,a2,0x4
    800060b2:	9532                	add	a0,a0,a2
    800060b4:	f9078793          	addi	a5,a5,-112
    800060b8:	97b6                	add	a5,a5,a3
    800060ba:	e11c                	sd	a5,0(a0)
  disk.desc[idx[2]].len = 1;
    800060bc:	629c                	ld	a5,0(a3)
    800060be:	97b2                	add	a5,a5,a2
    800060c0:	4605                	li	a2,1
    800060c2:	c790                	sw	a2,8(a5)
  disk.desc[idx[2]].flags = VRING_DESC_F_WRITE; // device writes the status
    800060c4:	4509                	li	a0,2
    800060c6:	00a79623          	sh	a0,12(a5)
  disk.desc[idx[2]].next = 0;
    800060ca:	00079723          	sh	zero,14(a5)

  // record struct buf for virtio_disk_intr().
  b->disk = 1;
    800060ce:	00caa223          	sw	a2,4(s5)
  disk.info[idx[0]].b = b;
    800060d2:	01573423          	sd	s5,8(a4)

  // tell the device the first index in our chain of descriptors.
  disk.avail->ring[disk.avail->idx % NUM] = idx[0];
    800060d6:	6698                	ld	a4,8(a3)
    800060d8:	00275783          	lhu	a5,2(a4)
    800060dc:	8b9d                	andi	a5,a5,7
    800060de:	0786                	slli	a5,a5,0x1
    800060e0:	97ba                	add	a5,a5,a4
    800060e2:	00b79223          	sh	a1,4(a5)

  __sync_synchronize();
    800060e6:	0ff0000f          	fence

  // tell the device another avail ring entry is available.
  disk.avail->idx += 1; // not % NUM ...
    800060ea:	6698                	ld	a4,8(a3)
    800060ec:	00275783          	lhu	a5,2(a4)
    800060f0:	2785                	addiw	a5,a5,1
    800060f2:	00f71123          	sh	a5,2(a4)

  __sync_synchronize();
    800060f6:	0ff0000f          	fence

  *R(VIRTIO_MMIO_QUEUE_NOTIFY) = 0; // value is queue number
    800060fa:	100017b7          	lui	a5,0x10001
    800060fe:	0407a823          	sw	zero,80(a5) # 10001050 <_entry-0x6fffefb0>

  // Wait for virtio_disk_intr() to say request has finished.
  while(b->disk == 1) {
    80006102:	004aa783          	lw	a5,4(s5)
    80006106:	02c79163          	bne	a5,a2,80006128 <virtio_disk_rw+0x1c4>
    sleep(b, &disk.vdisk_lock);
    8000610a:	0001c917          	auipc	s2,0x1c
    8000610e:	c5e90913          	addi	s2,s2,-930 # 80021d68 <disk+0x128>
  while(b->disk == 1) {
    80006112:	4485                	li	s1,1
    sleep(b, &disk.vdisk_lock);
    80006114:	85ca                	mv	a1,s2
    80006116:	8556                	mv	a0,s5
    80006118:	ffffc097          	auipc	ra,0xffffc
    8000611c:	fba080e7          	jalr	-70(ra) # 800020d2 <sleep>
  while(b->disk == 1) {
    80006120:	004aa783          	lw	a5,4(s5)
    80006124:	fe9788e3          	beq	a5,s1,80006114 <virtio_disk_rw+0x1b0>
  }

  disk.info[idx[0]].b = 0;
    80006128:	f8042903          	lw	s2,-128(s0)
    8000612c:	00290793          	addi	a5,s2,2
    80006130:	00479713          	slli	a4,a5,0x4
    80006134:	0001c797          	auipc	a5,0x1c
    80006138:	b0c78793          	addi	a5,a5,-1268 # 80021c40 <disk>
    8000613c:	97ba                	add	a5,a5,a4
    8000613e:	0007b423          	sd	zero,8(a5)
    int flag = disk.desc[i].flags;
    80006142:	0001c997          	auipc	s3,0x1c
    80006146:	afe98993          	addi	s3,s3,-1282 # 80021c40 <disk>
    8000614a:	00491713          	slli	a4,s2,0x4
    8000614e:	0009b783          	ld	a5,0(s3)
    80006152:	97ba                	add	a5,a5,a4
    80006154:	00c7d483          	lhu	s1,12(a5)
    int nxt = disk.desc[i].next;
    80006158:	854a                	mv	a0,s2
    8000615a:	00e7d903          	lhu	s2,14(a5)
    free_desc(i);
    8000615e:	00000097          	auipc	ra,0x0
    80006162:	b98080e7          	jalr	-1128(ra) # 80005cf6 <free_desc>
    if(flag & VRING_DESC_F_NEXT)
    80006166:	8885                	andi	s1,s1,1
    80006168:	f0ed                	bnez	s1,8000614a <virtio_disk_rw+0x1e6>
  free_chain(idx[0]);

  release(&disk.vdisk_lock);
    8000616a:	0001c517          	auipc	a0,0x1c
    8000616e:	bfe50513          	addi	a0,a0,-1026 # 80021d68 <disk+0x128>
    80006172:	ffffb097          	auipc	ra,0xffffb
    80006176:	b7c080e7          	jalr	-1156(ra) # 80000cee <release>
}
    8000617a:	70e6                	ld	ra,120(sp)
    8000617c:	7446                	ld	s0,112(sp)
    8000617e:	74a6                	ld	s1,104(sp)
    80006180:	7906                	ld	s2,96(sp)
    80006182:	69e6                	ld	s3,88(sp)
    80006184:	6a46                	ld	s4,80(sp)
    80006186:	6aa6                	ld	s5,72(sp)
    80006188:	6b06                	ld	s6,64(sp)
    8000618a:	7be2                	ld	s7,56(sp)
    8000618c:	7c42                	ld	s8,48(sp)
    8000618e:	7ca2                	ld	s9,40(sp)
    80006190:	7d02                	ld	s10,32(sp)
    80006192:	6de2                	ld	s11,24(sp)
    80006194:	6109                	addi	sp,sp,128
    80006196:	8082                	ret

0000000080006198 <virtio_disk_intr>:

void
virtio_disk_intr()
{
    80006198:	1101                	addi	sp,sp,-32
    8000619a:	ec06                	sd	ra,24(sp)
    8000619c:	e822                	sd	s0,16(sp)
    8000619e:	e426                	sd	s1,8(sp)
    800061a0:	1000                	addi	s0,sp,32
  acquire(&disk.vdisk_lock);
    800061a2:	0001c497          	auipc	s1,0x1c
    800061a6:	a9e48493          	addi	s1,s1,-1378 # 80021c40 <disk>
    800061aa:	0001c517          	auipc	a0,0x1c
    800061ae:	bbe50513          	addi	a0,a0,-1090 # 80021d68 <disk+0x128>
    800061b2:	ffffb097          	auipc	ra,0xffffb
    800061b6:	a88080e7          	jalr	-1400(ra) # 80000c3a <acquire>
  // we've seen this interrupt, which the following line does.
  // this may race with the device writing new entries to
  // the "used" ring, in which case we may process the new
  // completion entries in this interrupt, and have nothing to do
  // in the next interrupt, which is harmless.
  *R(VIRTIO_MMIO_INTERRUPT_ACK) = *R(VIRTIO_MMIO_INTERRUPT_STATUS) & 0x3;
    800061ba:	10001737          	lui	a4,0x10001
    800061be:	533c                	lw	a5,96(a4)
    800061c0:	8b8d                	andi	a5,a5,3
    800061c2:	d37c                	sw	a5,100(a4)

  __sync_synchronize();
    800061c4:	0ff0000f          	fence

  // the device increments disk.used->idx when it
  // adds an entry to the used ring.

  while(disk.used_idx != disk.used->idx){
    800061c8:	689c                	ld	a5,16(s1)
    800061ca:	0204d703          	lhu	a4,32(s1)
    800061ce:	0027d783          	lhu	a5,2(a5)
    800061d2:	04f70863          	beq	a4,a5,80006222 <virtio_disk_intr+0x8a>
    __sync_synchronize();
    800061d6:	0ff0000f          	fence
    int id = disk.used->ring[disk.used_idx % NUM].id;
    800061da:	6898                	ld	a4,16(s1)
    800061dc:	0204d783          	lhu	a5,32(s1)
    800061e0:	8b9d                	andi	a5,a5,7
    800061e2:	078e                	slli	a5,a5,0x3
    800061e4:	97ba                	add	a5,a5,a4
    800061e6:	43dc                	lw	a5,4(a5)

    if(disk.info[id].status != 0)
    800061e8:	00278713          	addi	a4,a5,2
    800061ec:	0712                	slli	a4,a4,0x4
    800061ee:	9726                	add	a4,a4,s1
    800061f0:	01074703          	lbu	a4,16(a4) # 10001010 <_entry-0x6fffeff0>
    800061f4:	e721                	bnez	a4,8000623c <virtio_disk_intr+0xa4>
      panic("virtio_disk_intr status");

    struct buf *b = disk.info[id].b;
    800061f6:	0789                	addi	a5,a5,2
    800061f8:	0792                	slli	a5,a5,0x4
    800061fa:	97a6                	add	a5,a5,s1
    800061fc:	6788                	ld	a0,8(a5)
    b->disk = 0;   // disk is done with buf
    800061fe:	00052223          	sw	zero,4(a0)
    wakeup(b);
    80006202:	ffffc097          	auipc	ra,0xffffc
    80006206:	f34080e7          	jalr	-204(ra) # 80002136 <wakeup>

    disk.used_idx += 1;
    8000620a:	0204d783          	lhu	a5,32(s1)
    8000620e:	2785                	addiw	a5,a5,1
    80006210:	17c2                	slli	a5,a5,0x30
    80006212:	93c1                	srli	a5,a5,0x30
    80006214:	02f49023          	sh	a5,32(s1)
  while(disk.used_idx != disk.used->idx){
    80006218:	6898                	ld	a4,16(s1)
    8000621a:	00275703          	lhu	a4,2(a4)
    8000621e:	faf71ce3          	bne	a4,a5,800061d6 <virtio_disk_intr+0x3e>
  }

  release(&disk.vdisk_lock);
    80006222:	0001c517          	auipc	a0,0x1c
    80006226:	b4650513          	addi	a0,a0,-1210 # 80021d68 <disk+0x128>
    8000622a:	ffffb097          	auipc	ra,0xffffb
    8000622e:	ac4080e7          	jalr	-1340(ra) # 80000cee <release>
}
    80006232:	60e2                	ld	ra,24(sp)
    80006234:	6442                	ld	s0,16(sp)
    80006236:	64a2                	ld	s1,8(sp)
    80006238:	6105                	addi	sp,sp,32
    8000623a:	8082                	ret
      panic("virtio_disk_intr status");
    8000623c:	00002517          	auipc	a0,0x2
    80006240:	62c50513          	addi	a0,a0,1580 # 80008868 <syscalls+0x3e0>
    80006244:	ffffa097          	auipc	ra,0xffffa
    80006248:	2fa080e7          	jalr	762(ra) # 8000053e <panic>
	...

0000000080007000 <_trampoline>:
    80007000:	14051073          	csrw	sscratch,a0
    80007004:	02000537          	lui	a0,0x2000
    80007008:	357d                	addiw	a0,a0,-1
    8000700a:	0536                	slli	a0,a0,0xd
    8000700c:	02153423          	sd	ra,40(a0) # 2000028 <_entry-0x7dffffd8>
    80007010:	02253823          	sd	sp,48(a0)
    80007014:	02353c23          	sd	gp,56(a0)
    80007018:	04453023          	sd	tp,64(a0)
    8000701c:	04553423          	sd	t0,72(a0)
    80007020:	04653823          	sd	t1,80(a0)
    80007024:	04753c23          	sd	t2,88(a0)
    80007028:	f120                	sd	s0,96(a0)
    8000702a:	f524                	sd	s1,104(a0)
    8000702c:	fd2c                	sd	a1,120(a0)
    8000702e:	e150                	sd	a2,128(a0)
    80007030:	e554                	sd	a3,136(a0)
    80007032:	e958                	sd	a4,144(a0)
    80007034:	ed5c                	sd	a5,152(a0)
    80007036:	0b053023          	sd	a6,160(a0)
    8000703a:	0b153423          	sd	a7,168(a0)
    8000703e:	0b253823          	sd	s2,176(a0)
    80007042:	0b353c23          	sd	s3,184(a0)
    80007046:	0d453023          	sd	s4,192(a0)
    8000704a:	0d553423          	sd	s5,200(a0)
    8000704e:	0d653823          	sd	s6,208(a0)
    80007052:	0d753c23          	sd	s7,216(a0)
    80007056:	0f853023          	sd	s8,224(a0)
    8000705a:	0f953423          	sd	s9,232(a0)
    8000705e:	0fa53823          	sd	s10,240(a0)
    80007062:	0fb53c23          	sd	s11,248(a0)
    80007066:	11c53023          	sd	t3,256(a0)
    8000706a:	11d53423          	sd	t4,264(a0)
    8000706e:	11e53823          	sd	t5,272(a0)
    80007072:	11f53c23          	sd	t6,280(a0)
    80007076:	140022f3          	csrr	t0,sscratch
    8000707a:	06553823          	sd	t0,112(a0)
    8000707e:	00853103          	ld	sp,8(a0)
    80007082:	02053203          	ld	tp,32(a0)
    80007086:	01053283          	ld	t0,16(a0)
    8000708a:	00053303          	ld	t1,0(a0)
    8000708e:	12000073          	sfence.vma
    80007092:	18031073          	csrw	satp,t1
    80007096:	12000073          	sfence.vma
    8000709a:	8282                	jr	t0

000000008000709c <userret>:
    8000709c:	12000073          	sfence.vma
    800070a0:	18051073          	csrw	satp,a0
    800070a4:	12000073          	sfence.vma
    800070a8:	02000537          	lui	a0,0x2000
    800070ac:	357d                	addiw	a0,a0,-1
    800070ae:	0536                	slli	a0,a0,0xd
    800070b0:	02853083          	ld	ra,40(a0) # 2000028 <_entry-0x7dffffd8>
    800070b4:	03053103          	ld	sp,48(a0)
    800070b8:	03853183          	ld	gp,56(a0)
    800070bc:	04053203          	ld	tp,64(a0)
    800070c0:	04853283          	ld	t0,72(a0)
    800070c4:	05053303          	ld	t1,80(a0)
    800070c8:	05853383          	ld	t2,88(a0)
    800070cc:	7120                	ld	s0,96(a0)
    800070ce:	7524                	ld	s1,104(a0)
    800070d0:	7d2c                	ld	a1,120(a0)
    800070d2:	6150                	ld	a2,128(a0)
    800070d4:	6554                	ld	a3,136(a0)
    800070d6:	6958                	ld	a4,144(a0)
    800070d8:	6d5c                	ld	a5,152(a0)
    800070da:	0a053803          	ld	a6,160(a0)
    800070de:	0a853883          	ld	a7,168(a0)
    800070e2:	0b053903          	ld	s2,176(a0)
    800070e6:	0b853983          	ld	s3,184(a0)
    800070ea:	0c053a03          	ld	s4,192(a0)
    800070ee:	0c853a83          	ld	s5,200(a0)
    800070f2:	0d053b03          	ld	s6,208(a0)
    800070f6:	0d853b83          	ld	s7,216(a0)
    800070fa:	0e053c03          	ld	s8,224(a0)
    800070fe:	0e853c83          	ld	s9,232(a0)
    80007102:	0f053d03          	ld	s10,240(a0)
    80007106:	0f853d83          	ld	s11,248(a0)
    8000710a:	10053e03          	ld	t3,256(a0)
    8000710e:	10853e83          	ld	t4,264(a0)
    80007112:	11053f03          	ld	t5,272(a0)
    80007116:	11853f83          	ld	t6,280(a0)
    8000711a:	7928                	ld	a0,112(a0)
    8000711c:	10200073          	sret
	...
