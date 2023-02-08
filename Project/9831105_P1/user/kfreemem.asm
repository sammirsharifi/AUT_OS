
user/_kfreemem:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <main>:
#include "user.h"

long
main(int argc, char *argv[])

{
   0:	1141                	addi	sp,sp,-16
   2:	e406                	sd	ra,8(sp)
   4:	e022                	sd	s0,0(sp)
   6:	0800                	addi	s0,sp,16
    printf("---------------------------------\n");
   8:	00001517          	auipc	a0,0x1
   c:	85850513          	addi	a0,a0,-1960 # 860 <malloc+0xec>
  10:	00000097          	auipc	ra,0x0
  14:	6a6080e7          	jalr	1702(ra) # 6b6 <printf>
    printf("xv6 system memory: ");
  18:	00001517          	auipc	a0,0x1
  1c:	87050513          	addi	a0,a0,-1936 # 888 <malloc+0x114>
  20:	00000097          	auipc	ra,0x0
  24:	696080e7          	jalr	1686(ra) # 6b6 <printf>
    printf("%d byte.\n", 128*1024*1024);
  28:	080005b7          	lui	a1,0x8000
  2c:	00001517          	auipc	a0,0x1
  30:	87450513          	addi	a0,a0,-1932 # 8a0 <malloc+0x12c>
  34:	00000097          	auipc	ra,0x0
  38:	682080e7          	jalr	1666(ra) # 6b6 <printf>
    printf("xv6 free   memory: ");
  3c:	00001517          	auipc	a0,0x1
  40:	87450513          	addi	a0,a0,-1932 # 8b0 <malloc+0x13c>
  44:	00000097          	auipc	ra,0x0
  48:	672080e7          	jalr	1650(ra) # 6b6 <printf>
    printf("%d byte.\n",kfreemem());
  4c:	00000097          	auipc	ra,0x0
  50:	38a080e7          	jalr	906(ra) # 3d6 <kfreemem>
  54:	85aa                	mv	a1,a0
  56:	00001517          	auipc	a0,0x1
  5a:	84a50513          	addi	a0,a0,-1974 # 8a0 <malloc+0x12c>
  5e:	00000097          	auipc	ra,0x0
  62:	658080e7          	jalr	1624(ra) # 6b6 <printf>
    printf("xv6 busy   memory: ");
  66:	00001517          	auipc	a0,0x1
  6a:	86250513          	addi	a0,a0,-1950 # 8c8 <malloc+0x154>
  6e:	00000097          	auipc	ra,0x0
  72:	648080e7          	jalr	1608(ra) # 6b6 <printf>
    printf("%d    byte.\n",128*1024*1024-kfreemem());
  76:	00000097          	auipc	ra,0x0
  7a:	360080e7          	jalr	864(ra) # 3d6 <kfreemem>
  7e:	080005b7          	lui	a1,0x8000
  82:	9d89                	subw	a1,a1,a0
  84:	00001517          	auipc	a0,0x1
  88:	85c50513          	addi	a0,a0,-1956 # 8e0 <malloc+0x16c>
  8c:	00000097          	auipc	ra,0x0
  90:	62a080e7          	jalr	1578(ra) # 6b6 <printf>
    printf("---------------------------------\n");
  94:	00000517          	auipc	a0,0x0
  98:	7cc50513          	addi	a0,a0,1996 # 860 <malloc+0xec>
  9c:	00000097          	auipc	ra,0x0
  a0:	61a080e7          	jalr	1562(ra) # 6b6 <printf>

    exit(0);
  a4:	4501                	li	a0,0
  a6:	00000097          	auipc	ra,0x0
  aa:	290080e7          	jalr	656(ra) # 336 <exit>

00000000000000ae <_main>:
//
// wrapper so that it's OK if main() does not call exit().
//
void
_main()
{
  ae:	1141                	addi	sp,sp,-16
  b0:	e406                	sd	ra,8(sp)
  b2:	e022                	sd	s0,0(sp)
  b4:	0800                	addi	s0,sp,16
  extern int main();
  main();
  b6:	00000097          	auipc	ra,0x0
  ba:	f4a080e7          	jalr	-182(ra) # 0 <main>
  exit(0);
  be:	4501                	li	a0,0
  c0:	00000097          	auipc	ra,0x0
  c4:	276080e7          	jalr	630(ra) # 336 <exit>

00000000000000c8 <strcpy>:
}

char*
strcpy(char *s, const char *t)
{
  c8:	1141                	addi	sp,sp,-16
  ca:	e422                	sd	s0,8(sp)
  cc:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
  ce:	87aa                	mv	a5,a0
  d0:	0585                	addi	a1,a1,1
  d2:	0785                	addi	a5,a5,1
  d4:	fff5c703          	lbu	a4,-1(a1) # 7ffffff <base+0x7ffefef>
  d8:	fee78fa3          	sb	a4,-1(a5)
  dc:	fb75                	bnez	a4,d0 <strcpy+0x8>
    ;
  return os;
}
  de:	6422                	ld	s0,8(sp)
  e0:	0141                	addi	sp,sp,16
  e2:	8082                	ret

00000000000000e4 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  e4:	1141                	addi	sp,sp,-16
  e6:	e422                	sd	s0,8(sp)
  e8:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
  ea:	00054783          	lbu	a5,0(a0)
  ee:	cb91                	beqz	a5,102 <strcmp+0x1e>
  f0:	0005c703          	lbu	a4,0(a1)
  f4:	00f71763          	bne	a4,a5,102 <strcmp+0x1e>
    p++, q++;
  f8:	0505                	addi	a0,a0,1
  fa:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
  fc:	00054783          	lbu	a5,0(a0)
 100:	fbe5                	bnez	a5,f0 <strcmp+0xc>
  return (uchar)*p - (uchar)*q;
 102:	0005c503          	lbu	a0,0(a1)
}
 106:	40a7853b          	subw	a0,a5,a0
 10a:	6422                	ld	s0,8(sp)
 10c:	0141                	addi	sp,sp,16
 10e:	8082                	ret

0000000000000110 <strlen>:

uint
strlen(const char *s)
{
 110:	1141                	addi	sp,sp,-16
 112:	e422                	sd	s0,8(sp)
 114:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
 116:	00054783          	lbu	a5,0(a0)
 11a:	cf91                	beqz	a5,136 <strlen+0x26>
 11c:	0505                	addi	a0,a0,1
 11e:	87aa                	mv	a5,a0
 120:	4685                	li	a3,1
 122:	9e89                	subw	a3,a3,a0
 124:	00f6853b          	addw	a0,a3,a5
 128:	0785                	addi	a5,a5,1
 12a:	fff7c703          	lbu	a4,-1(a5)
 12e:	fb7d                	bnez	a4,124 <strlen+0x14>
    ;
  return n;
}
 130:	6422                	ld	s0,8(sp)
 132:	0141                	addi	sp,sp,16
 134:	8082                	ret
  for(n = 0; s[n]; n++)
 136:	4501                	li	a0,0
 138:	bfe5                	j	130 <strlen+0x20>

000000000000013a <memset>:

void*
memset(void *dst, int c, uint n)
{
 13a:	1141                	addi	sp,sp,-16
 13c:	e422                	sd	s0,8(sp)
 13e:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
 140:	ca19                	beqz	a2,156 <memset+0x1c>
 142:	87aa                	mv	a5,a0
 144:	1602                	slli	a2,a2,0x20
 146:	9201                	srli	a2,a2,0x20
 148:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
 14c:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
 150:	0785                	addi	a5,a5,1
 152:	fee79de3          	bne	a5,a4,14c <memset+0x12>
  }
  return dst;
}
 156:	6422                	ld	s0,8(sp)
 158:	0141                	addi	sp,sp,16
 15a:	8082                	ret

000000000000015c <strchr>:

char*
strchr(const char *s, char c)
{
 15c:	1141                	addi	sp,sp,-16
 15e:	e422                	sd	s0,8(sp)
 160:	0800                	addi	s0,sp,16
  for(; *s; s++)
 162:	00054783          	lbu	a5,0(a0)
 166:	cb99                	beqz	a5,17c <strchr+0x20>
    if(*s == c)
 168:	00f58763          	beq	a1,a5,176 <strchr+0x1a>
  for(; *s; s++)
 16c:	0505                	addi	a0,a0,1
 16e:	00054783          	lbu	a5,0(a0)
 172:	fbfd                	bnez	a5,168 <strchr+0xc>
      return (char*)s;
  return 0;
 174:	4501                	li	a0,0
}
 176:	6422                	ld	s0,8(sp)
 178:	0141                	addi	sp,sp,16
 17a:	8082                	ret
  return 0;
 17c:	4501                	li	a0,0
 17e:	bfe5                	j	176 <strchr+0x1a>

0000000000000180 <gets>:

char*
gets(char *buf, int max)
{
 180:	711d                	addi	sp,sp,-96
 182:	ec86                	sd	ra,88(sp)
 184:	e8a2                	sd	s0,80(sp)
 186:	e4a6                	sd	s1,72(sp)
 188:	e0ca                	sd	s2,64(sp)
 18a:	fc4e                	sd	s3,56(sp)
 18c:	f852                	sd	s4,48(sp)
 18e:	f456                	sd	s5,40(sp)
 190:	f05a                	sd	s6,32(sp)
 192:	ec5e                	sd	s7,24(sp)
 194:	1080                	addi	s0,sp,96
 196:	8baa                	mv	s7,a0
 198:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 19a:	892a                	mv	s2,a0
 19c:	4481                	li	s1,0
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
 19e:	4aa9                	li	s5,10
 1a0:	4b35                	li	s6,13
  for(i=0; i+1 < max; ){
 1a2:	89a6                	mv	s3,s1
 1a4:	2485                	addiw	s1,s1,1
 1a6:	0344d863          	bge	s1,s4,1d6 <gets+0x56>
    cc = read(0, &c, 1);
 1aa:	4605                	li	a2,1
 1ac:	faf40593          	addi	a1,s0,-81
 1b0:	4501                	li	a0,0
 1b2:	00000097          	auipc	ra,0x0
 1b6:	19c080e7          	jalr	412(ra) # 34e <read>
    if(cc < 1)
 1ba:	00a05e63          	blez	a0,1d6 <gets+0x56>
    buf[i++] = c;
 1be:	faf44783          	lbu	a5,-81(s0)
 1c2:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
 1c6:	01578763          	beq	a5,s5,1d4 <gets+0x54>
 1ca:	0905                	addi	s2,s2,1
 1cc:	fd679be3          	bne	a5,s6,1a2 <gets+0x22>
  for(i=0; i+1 < max; ){
 1d0:	89a6                	mv	s3,s1
 1d2:	a011                	j	1d6 <gets+0x56>
 1d4:	89a6                	mv	s3,s1
      break;
  }
  buf[i] = '\0';
 1d6:	99de                	add	s3,s3,s7
 1d8:	00098023          	sb	zero,0(s3)
  return buf;
}
 1dc:	855e                	mv	a0,s7
 1de:	60e6                	ld	ra,88(sp)
 1e0:	6446                	ld	s0,80(sp)
 1e2:	64a6                	ld	s1,72(sp)
 1e4:	6906                	ld	s2,64(sp)
 1e6:	79e2                	ld	s3,56(sp)
 1e8:	7a42                	ld	s4,48(sp)
 1ea:	7aa2                	ld	s5,40(sp)
 1ec:	7b02                	ld	s6,32(sp)
 1ee:	6be2                	ld	s7,24(sp)
 1f0:	6125                	addi	sp,sp,96
 1f2:	8082                	ret

00000000000001f4 <stat>:

int
stat(const char *n, struct stat *st)
{
 1f4:	1101                	addi	sp,sp,-32
 1f6:	ec06                	sd	ra,24(sp)
 1f8:	e822                	sd	s0,16(sp)
 1fa:	e426                	sd	s1,8(sp)
 1fc:	e04a                	sd	s2,0(sp)
 1fe:	1000                	addi	s0,sp,32
 200:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 202:	4581                	li	a1,0
 204:	00000097          	auipc	ra,0x0
 208:	172080e7          	jalr	370(ra) # 376 <open>
  if(fd < 0)
 20c:	02054563          	bltz	a0,236 <stat+0x42>
 210:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
 212:	85ca                	mv	a1,s2
 214:	00000097          	auipc	ra,0x0
 218:	17a080e7          	jalr	378(ra) # 38e <fstat>
 21c:	892a                	mv	s2,a0
  close(fd);
 21e:	8526                	mv	a0,s1
 220:	00000097          	auipc	ra,0x0
 224:	13e080e7          	jalr	318(ra) # 35e <close>
  return r;
}
 228:	854a                	mv	a0,s2
 22a:	60e2                	ld	ra,24(sp)
 22c:	6442                	ld	s0,16(sp)
 22e:	64a2                	ld	s1,8(sp)
 230:	6902                	ld	s2,0(sp)
 232:	6105                	addi	sp,sp,32
 234:	8082                	ret
    return -1;
 236:	597d                	li	s2,-1
 238:	bfc5                	j	228 <stat+0x34>

000000000000023a <atoi>:

int
atoi(const char *s)
{
 23a:	1141                	addi	sp,sp,-16
 23c:	e422                	sd	s0,8(sp)
 23e:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 240:	00054603          	lbu	a2,0(a0)
 244:	fd06079b          	addiw	a5,a2,-48
 248:	0ff7f793          	andi	a5,a5,255
 24c:	4725                	li	a4,9
 24e:	02f76963          	bltu	a4,a5,280 <atoi+0x46>
 252:	86aa                	mv	a3,a0
  n = 0;
 254:	4501                	li	a0,0
  while('0' <= *s && *s <= '9')
 256:	45a5                	li	a1,9
    n = n*10 + *s++ - '0';
 258:	0685                	addi	a3,a3,1
 25a:	0025179b          	slliw	a5,a0,0x2
 25e:	9fa9                	addw	a5,a5,a0
 260:	0017979b          	slliw	a5,a5,0x1
 264:	9fb1                	addw	a5,a5,a2
 266:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
 26a:	0006c603          	lbu	a2,0(a3)
 26e:	fd06071b          	addiw	a4,a2,-48
 272:	0ff77713          	andi	a4,a4,255
 276:	fee5f1e3          	bgeu	a1,a4,258 <atoi+0x1e>
  return n;
}
 27a:	6422                	ld	s0,8(sp)
 27c:	0141                	addi	sp,sp,16
 27e:	8082                	ret
  n = 0;
 280:	4501                	li	a0,0
 282:	bfe5                	j	27a <atoi+0x40>

0000000000000284 <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 284:	1141                	addi	sp,sp,-16
 286:	e422                	sd	s0,8(sp)
 288:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
 28a:	02b57463          	bgeu	a0,a1,2b2 <memmove+0x2e>
    while(n-- > 0)
 28e:	00c05f63          	blez	a2,2ac <memmove+0x28>
 292:	1602                	slli	a2,a2,0x20
 294:	9201                	srli	a2,a2,0x20
 296:	00c507b3          	add	a5,a0,a2
  dst = vdst;
 29a:	872a                	mv	a4,a0
      *dst++ = *src++;
 29c:	0585                	addi	a1,a1,1
 29e:	0705                	addi	a4,a4,1
 2a0:	fff5c683          	lbu	a3,-1(a1)
 2a4:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
 2a8:	fee79ae3          	bne	a5,a4,29c <memmove+0x18>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
 2ac:	6422                	ld	s0,8(sp)
 2ae:	0141                	addi	sp,sp,16
 2b0:	8082                	ret
    dst += n;
 2b2:	00c50733          	add	a4,a0,a2
    src += n;
 2b6:	95b2                	add	a1,a1,a2
    while(n-- > 0)
 2b8:	fec05ae3          	blez	a2,2ac <memmove+0x28>
 2bc:	fff6079b          	addiw	a5,a2,-1
 2c0:	1782                	slli	a5,a5,0x20
 2c2:	9381                	srli	a5,a5,0x20
 2c4:	fff7c793          	not	a5,a5
 2c8:	97ba                	add	a5,a5,a4
      *--dst = *--src;
 2ca:	15fd                	addi	a1,a1,-1
 2cc:	177d                	addi	a4,a4,-1
 2ce:	0005c683          	lbu	a3,0(a1)
 2d2:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
 2d6:	fee79ae3          	bne	a5,a4,2ca <memmove+0x46>
 2da:	bfc9                	j	2ac <memmove+0x28>

00000000000002dc <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
 2dc:	1141                	addi	sp,sp,-16
 2de:	e422                	sd	s0,8(sp)
 2e0:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
 2e2:	ca05                	beqz	a2,312 <memcmp+0x36>
 2e4:	fff6069b          	addiw	a3,a2,-1
 2e8:	1682                	slli	a3,a3,0x20
 2ea:	9281                	srli	a3,a3,0x20
 2ec:	0685                	addi	a3,a3,1
 2ee:	96aa                	add	a3,a3,a0
    if (*p1 != *p2) {
 2f0:	00054783          	lbu	a5,0(a0)
 2f4:	0005c703          	lbu	a4,0(a1)
 2f8:	00e79863          	bne	a5,a4,308 <memcmp+0x2c>
      return *p1 - *p2;
    }
    p1++;
 2fc:	0505                	addi	a0,a0,1
    p2++;
 2fe:	0585                	addi	a1,a1,1
  while (n-- > 0) {
 300:	fed518e3          	bne	a0,a3,2f0 <memcmp+0x14>
  }
  return 0;
 304:	4501                	li	a0,0
 306:	a019                	j	30c <memcmp+0x30>
      return *p1 - *p2;
 308:	40e7853b          	subw	a0,a5,a4
}
 30c:	6422                	ld	s0,8(sp)
 30e:	0141                	addi	sp,sp,16
 310:	8082                	ret
  return 0;
 312:	4501                	li	a0,0
 314:	bfe5                	j	30c <memcmp+0x30>

0000000000000316 <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
 316:	1141                	addi	sp,sp,-16
 318:	e406                	sd	ra,8(sp)
 31a:	e022                	sd	s0,0(sp)
 31c:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
 31e:	00000097          	auipc	ra,0x0
 322:	f66080e7          	jalr	-154(ra) # 284 <memmove>
}
 326:	60a2                	ld	ra,8(sp)
 328:	6402                	ld	s0,0(sp)
 32a:	0141                	addi	sp,sp,16
 32c:	8082                	ret

000000000000032e <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 32e:	4885                	li	a7,1
 ecall
 330:	00000073          	ecall
 ret
 334:	8082                	ret

0000000000000336 <exit>:
.global exit
exit:
 li a7, SYS_exit
 336:	4889                	li	a7,2
 ecall
 338:	00000073          	ecall
 ret
 33c:	8082                	ret

000000000000033e <wait>:
.global wait
wait:
 li a7, SYS_wait
 33e:	488d                	li	a7,3
 ecall
 340:	00000073          	ecall
 ret
 344:	8082                	ret

0000000000000346 <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 346:	4891                	li	a7,4
 ecall
 348:	00000073          	ecall
 ret
 34c:	8082                	ret

000000000000034e <read>:
.global read
read:
 li a7, SYS_read
 34e:	4895                	li	a7,5
 ecall
 350:	00000073          	ecall
 ret
 354:	8082                	ret

0000000000000356 <write>:
.global write
write:
 li a7, SYS_write
 356:	48c1                	li	a7,16
 ecall
 358:	00000073          	ecall
 ret
 35c:	8082                	ret

000000000000035e <close>:
.global close
close:
 li a7, SYS_close
 35e:	48d5                	li	a7,21
 ecall
 360:	00000073          	ecall
 ret
 364:	8082                	ret

0000000000000366 <kill>:
.global kill
kill:
 li a7, SYS_kill
 366:	4899                	li	a7,6
 ecall
 368:	00000073          	ecall
 ret
 36c:	8082                	ret

000000000000036e <exec>:
.global exec
exec:
 li a7, SYS_exec
 36e:	489d                	li	a7,7
 ecall
 370:	00000073          	ecall
 ret
 374:	8082                	ret

0000000000000376 <open>:
.global open
open:
 li a7, SYS_open
 376:	48bd                	li	a7,15
 ecall
 378:	00000073          	ecall
 ret
 37c:	8082                	ret

000000000000037e <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 37e:	48c5                	li	a7,17
 ecall
 380:	00000073          	ecall
 ret
 384:	8082                	ret

0000000000000386 <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 386:	48c9                	li	a7,18
 ecall
 388:	00000073          	ecall
 ret
 38c:	8082                	ret

000000000000038e <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 38e:	48a1                	li	a7,8
 ecall
 390:	00000073          	ecall
 ret
 394:	8082                	ret

0000000000000396 <link>:
.global link
link:
 li a7, SYS_link
 396:	48cd                	li	a7,19
 ecall
 398:	00000073          	ecall
 ret
 39c:	8082                	ret

000000000000039e <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 39e:	48d1                	li	a7,20
 ecall
 3a0:	00000073          	ecall
 ret
 3a4:	8082                	ret

00000000000003a6 <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 3a6:	48a5                	li	a7,9
 ecall
 3a8:	00000073          	ecall
 ret
 3ac:	8082                	ret

00000000000003ae <dup>:
.global dup
dup:
 li a7, SYS_dup
 3ae:	48a9                	li	a7,10
 ecall
 3b0:	00000073          	ecall
 ret
 3b4:	8082                	ret

00000000000003b6 <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 3b6:	48ad                	li	a7,11
 ecall
 3b8:	00000073          	ecall
 ret
 3bc:	8082                	ret

00000000000003be <sbrk>:
.global sbrk
sbrk:
 li a7, SYS_sbrk
 3be:	48b1                	li	a7,12
 ecall
 3c0:	00000073          	ecall
 ret
 3c4:	8082                	ret

00000000000003c6 <sleep>:
.global sleep
sleep:
 li a7, SYS_sleep
 3c6:	48b5                	li	a7,13
 ecall
 3c8:	00000073          	ecall
 ret
 3cc:	8082                	ret

00000000000003ce <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 3ce:	48b9                	li	a7,14
 ecall
 3d0:	00000073          	ecall
 ret
 3d4:	8082                	ret

00000000000003d6 <kfreemem>:
.global kfreemem
kfreemem:
 li a7, SYS_kfreemem
 3d6:	48d9                	li	a7,22
 ecall
 3d8:	00000073          	ecall
 ret
 3dc:	8082                	ret

00000000000003de <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
 3de:	1101                	addi	sp,sp,-32
 3e0:	ec06                	sd	ra,24(sp)
 3e2:	e822                	sd	s0,16(sp)
 3e4:	1000                	addi	s0,sp,32
 3e6:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 3ea:	4605                	li	a2,1
 3ec:	fef40593          	addi	a1,s0,-17
 3f0:	00000097          	auipc	ra,0x0
 3f4:	f66080e7          	jalr	-154(ra) # 356 <write>
}
 3f8:	60e2                	ld	ra,24(sp)
 3fa:	6442                	ld	s0,16(sp)
 3fc:	6105                	addi	sp,sp,32
 3fe:	8082                	ret

0000000000000400 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 400:	7139                	addi	sp,sp,-64
 402:	fc06                	sd	ra,56(sp)
 404:	f822                	sd	s0,48(sp)
 406:	f426                	sd	s1,40(sp)
 408:	f04a                	sd	s2,32(sp)
 40a:	ec4e                	sd	s3,24(sp)
 40c:	0080                	addi	s0,sp,64
 40e:	84aa                	mv	s1,a0
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
 410:	c299                	beqz	a3,416 <printint+0x16>
 412:	0805c863          	bltz	a1,4a2 <printint+0xa2>
    neg = 1;
    x = -xx;
  } else {
    x = xx;
 416:	2581                	sext.w	a1,a1
  neg = 0;
 418:	4881                	li	a7,0
 41a:	fc040693          	addi	a3,s0,-64
  }

  i = 0;
 41e:	4701                	li	a4,0
  do{
    buf[i++] = digits[x % base];
 420:	2601                	sext.w	a2,a2
 422:	00000517          	auipc	a0,0x0
 426:	4d650513          	addi	a0,a0,1238 # 8f8 <digits>
 42a:	883a                	mv	a6,a4
 42c:	2705                	addiw	a4,a4,1
 42e:	02c5f7bb          	remuw	a5,a1,a2
 432:	1782                	slli	a5,a5,0x20
 434:	9381                	srli	a5,a5,0x20
 436:	97aa                	add	a5,a5,a0
 438:	0007c783          	lbu	a5,0(a5)
 43c:	00f68023          	sb	a5,0(a3)
  }while((x /= base) != 0);
 440:	0005879b          	sext.w	a5,a1
 444:	02c5d5bb          	divuw	a1,a1,a2
 448:	0685                	addi	a3,a3,1
 44a:	fec7f0e3          	bgeu	a5,a2,42a <printint+0x2a>
  if(neg)
 44e:	00088b63          	beqz	a7,464 <printint+0x64>
    buf[i++] = '-';
 452:	fd040793          	addi	a5,s0,-48
 456:	973e                	add	a4,a4,a5
 458:	02d00793          	li	a5,45
 45c:	fef70823          	sb	a5,-16(a4)
 460:	0028071b          	addiw	a4,a6,2

  while(--i >= 0)
 464:	02e05863          	blez	a4,494 <printint+0x94>
 468:	fc040793          	addi	a5,s0,-64
 46c:	00e78933          	add	s2,a5,a4
 470:	fff78993          	addi	s3,a5,-1
 474:	99ba                	add	s3,s3,a4
 476:	377d                	addiw	a4,a4,-1
 478:	1702                	slli	a4,a4,0x20
 47a:	9301                	srli	a4,a4,0x20
 47c:	40e989b3          	sub	s3,s3,a4
    putc(fd, buf[i]);
 480:	fff94583          	lbu	a1,-1(s2)
 484:	8526                	mv	a0,s1
 486:	00000097          	auipc	ra,0x0
 48a:	f58080e7          	jalr	-168(ra) # 3de <putc>
  while(--i >= 0)
 48e:	197d                	addi	s2,s2,-1
 490:	ff3918e3          	bne	s2,s3,480 <printint+0x80>
}
 494:	70e2                	ld	ra,56(sp)
 496:	7442                	ld	s0,48(sp)
 498:	74a2                	ld	s1,40(sp)
 49a:	7902                	ld	s2,32(sp)
 49c:	69e2                	ld	s3,24(sp)
 49e:	6121                	addi	sp,sp,64
 4a0:	8082                	ret
    x = -xx;
 4a2:	40b005bb          	negw	a1,a1
    neg = 1;
 4a6:	4885                	li	a7,1
    x = -xx;
 4a8:	bf8d                	j	41a <printint+0x1a>

00000000000004aa <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 4aa:	7119                	addi	sp,sp,-128
 4ac:	fc86                	sd	ra,120(sp)
 4ae:	f8a2                	sd	s0,112(sp)
 4b0:	f4a6                	sd	s1,104(sp)
 4b2:	f0ca                	sd	s2,96(sp)
 4b4:	ecce                	sd	s3,88(sp)
 4b6:	e8d2                	sd	s4,80(sp)
 4b8:	e4d6                	sd	s5,72(sp)
 4ba:	e0da                	sd	s6,64(sp)
 4bc:	fc5e                	sd	s7,56(sp)
 4be:	f862                	sd	s8,48(sp)
 4c0:	f466                	sd	s9,40(sp)
 4c2:	f06a                	sd	s10,32(sp)
 4c4:	ec6e                	sd	s11,24(sp)
 4c6:	0100                	addi	s0,sp,128
  char *s;
  int c, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
 4c8:	0005c903          	lbu	s2,0(a1)
 4cc:	18090f63          	beqz	s2,66a <vprintf+0x1c0>
 4d0:	8aaa                	mv	s5,a0
 4d2:	8b32                	mv	s6,a2
 4d4:	00158493          	addi	s1,a1,1
  state = 0;
 4d8:	4981                	li	s3,0
      if(c == '%'){
        state = '%';
      } else {
        putc(fd, c);
      }
    } else if(state == '%'){
 4da:	02500a13          	li	s4,37
      if(c == 'd'){
 4de:	06400c13          	li	s8,100
        printint(fd, va_arg(ap, int), 10, 1);
      } else if(c == 'l') {
 4e2:	06c00c93          	li	s9,108
        printint(fd, va_arg(ap, uint64), 10, 0);
      } else if(c == 'x') {
 4e6:	07800d13          	li	s10,120
        printint(fd, va_arg(ap, int), 16, 0);
      } else if(c == 'p') {
 4ea:	07000d93          	li	s11,112
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 4ee:	00000b97          	auipc	s7,0x0
 4f2:	40ab8b93          	addi	s7,s7,1034 # 8f8 <digits>
 4f6:	a839                	j	514 <vprintf+0x6a>
        putc(fd, c);
 4f8:	85ca                	mv	a1,s2
 4fa:	8556                	mv	a0,s5
 4fc:	00000097          	auipc	ra,0x0
 500:	ee2080e7          	jalr	-286(ra) # 3de <putc>
 504:	a019                	j	50a <vprintf+0x60>
    } else if(state == '%'){
 506:	01498f63          	beq	s3,s4,524 <vprintf+0x7a>
  for(i = 0; fmt[i]; i++){
 50a:	0485                	addi	s1,s1,1
 50c:	fff4c903          	lbu	s2,-1(s1)
 510:	14090d63          	beqz	s2,66a <vprintf+0x1c0>
    c = fmt[i] & 0xff;
 514:	0009079b          	sext.w	a5,s2
    if(state == 0){
 518:	fe0997e3          	bnez	s3,506 <vprintf+0x5c>
      if(c == '%'){
 51c:	fd479ee3          	bne	a5,s4,4f8 <vprintf+0x4e>
        state = '%';
 520:	89be                	mv	s3,a5
 522:	b7e5                	j	50a <vprintf+0x60>
      if(c == 'd'){
 524:	05878063          	beq	a5,s8,564 <vprintf+0xba>
      } else if(c == 'l') {
 528:	05978c63          	beq	a5,s9,580 <vprintf+0xd6>
      } else if(c == 'x') {
 52c:	07a78863          	beq	a5,s10,59c <vprintf+0xf2>
      } else if(c == 'p') {
 530:	09b78463          	beq	a5,s11,5b8 <vprintf+0x10e>
        printptr(fd, va_arg(ap, uint64));
      } else if(c == 's'){
 534:	07300713          	li	a4,115
 538:	0ce78663          	beq	a5,a4,604 <vprintf+0x15a>
          s = "(null)";
        while(*s != 0){
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
 53c:	06300713          	li	a4,99
 540:	0ee78e63          	beq	a5,a4,63c <vprintf+0x192>
        putc(fd, va_arg(ap, uint));
      } else if(c == '%'){
 544:	11478863          	beq	a5,s4,654 <vprintf+0x1aa>
        putc(fd, c);
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 548:	85d2                	mv	a1,s4
 54a:	8556                	mv	a0,s5
 54c:	00000097          	auipc	ra,0x0
 550:	e92080e7          	jalr	-366(ra) # 3de <putc>
        putc(fd, c);
 554:	85ca                	mv	a1,s2
 556:	8556                	mv	a0,s5
 558:	00000097          	auipc	ra,0x0
 55c:	e86080e7          	jalr	-378(ra) # 3de <putc>
      }
      state = 0;
 560:	4981                	li	s3,0
 562:	b765                	j	50a <vprintf+0x60>
        printint(fd, va_arg(ap, int), 10, 1);
 564:	008b0913          	addi	s2,s6,8
 568:	4685                	li	a3,1
 56a:	4629                	li	a2,10
 56c:	000b2583          	lw	a1,0(s6)
 570:	8556                	mv	a0,s5
 572:	00000097          	auipc	ra,0x0
 576:	e8e080e7          	jalr	-370(ra) # 400 <printint>
 57a:	8b4a                	mv	s6,s2
      state = 0;
 57c:	4981                	li	s3,0
 57e:	b771                	j	50a <vprintf+0x60>
        printint(fd, va_arg(ap, uint64), 10, 0);
 580:	008b0913          	addi	s2,s6,8
 584:	4681                	li	a3,0
 586:	4629                	li	a2,10
 588:	000b2583          	lw	a1,0(s6)
 58c:	8556                	mv	a0,s5
 58e:	00000097          	auipc	ra,0x0
 592:	e72080e7          	jalr	-398(ra) # 400 <printint>
 596:	8b4a                	mv	s6,s2
      state = 0;
 598:	4981                	li	s3,0
 59a:	bf85                	j	50a <vprintf+0x60>
        printint(fd, va_arg(ap, int), 16, 0);
 59c:	008b0913          	addi	s2,s6,8
 5a0:	4681                	li	a3,0
 5a2:	4641                	li	a2,16
 5a4:	000b2583          	lw	a1,0(s6)
 5a8:	8556                	mv	a0,s5
 5aa:	00000097          	auipc	ra,0x0
 5ae:	e56080e7          	jalr	-426(ra) # 400 <printint>
 5b2:	8b4a                	mv	s6,s2
      state = 0;
 5b4:	4981                	li	s3,0
 5b6:	bf91                	j	50a <vprintf+0x60>
        printptr(fd, va_arg(ap, uint64));
 5b8:	008b0793          	addi	a5,s6,8
 5bc:	f8f43423          	sd	a5,-120(s0)
 5c0:	000b3983          	ld	s3,0(s6)
  putc(fd, '0');
 5c4:	03000593          	li	a1,48
 5c8:	8556                	mv	a0,s5
 5ca:	00000097          	auipc	ra,0x0
 5ce:	e14080e7          	jalr	-492(ra) # 3de <putc>
  putc(fd, 'x');
 5d2:	85ea                	mv	a1,s10
 5d4:	8556                	mv	a0,s5
 5d6:	00000097          	auipc	ra,0x0
 5da:	e08080e7          	jalr	-504(ra) # 3de <putc>
 5de:	4941                	li	s2,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 5e0:	03c9d793          	srli	a5,s3,0x3c
 5e4:	97de                	add	a5,a5,s7
 5e6:	0007c583          	lbu	a1,0(a5)
 5ea:	8556                	mv	a0,s5
 5ec:	00000097          	auipc	ra,0x0
 5f0:	df2080e7          	jalr	-526(ra) # 3de <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 5f4:	0992                	slli	s3,s3,0x4
 5f6:	397d                	addiw	s2,s2,-1
 5f8:	fe0914e3          	bnez	s2,5e0 <vprintf+0x136>
        printptr(fd, va_arg(ap, uint64));
 5fc:	f8843b03          	ld	s6,-120(s0)
      state = 0;
 600:	4981                	li	s3,0
 602:	b721                	j	50a <vprintf+0x60>
        s = va_arg(ap, char*);
 604:	008b0993          	addi	s3,s6,8
 608:	000b3903          	ld	s2,0(s6)
        if(s == 0)
 60c:	02090163          	beqz	s2,62e <vprintf+0x184>
        while(*s != 0){
 610:	00094583          	lbu	a1,0(s2)
 614:	c9a1                	beqz	a1,664 <vprintf+0x1ba>
          putc(fd, *s);
 616:	8556                	mv	a0,s5
 618:	00000097          	auipc	ra,0x0
 61c:	dc6080e7          	jalr	-570(ra) # 3de <putc>
          s++;
 620:	0905                	addi	s2,s2,1
        while(*s != 0){
 622:	00094583          	lbu	a1,0(s2)
 626:	f9e5                	bnez	a1,616 <vprintf+0x16c>
        s = va_arg(ap, char*);
 628:	8b4e                	mv	s6,s3
      state = 0;
 62a:	4981                	li	s3,0
 62c:	bdf9                	j	50a <vprintf+0x60>
          s = "(null)";
 62e:	00000917          	auipc	s2,0x0
 632:	2c290913          	addi	s2,s2,706 # 8f0 <malloc+0x17c>
        while(*s != 0){
 636:	02800593          	li	a1,40
 63a:	bff1                	j	616 <vprintf+0x16c>
        putc(fd, va_arg(ap, uint));
 63c:	008b0913          	addi	s2,s6,8
 640:	000b4583          	lbu	a1,0(s6)
 644:	8556                	mv	a0,s5
 646:	00000097          	auipc	ra,0x0
 64a:	d98080e7          	jalr	-616(ra) # 3de <putc>
 64e:	8b4a                	mv	s6,s2
      state = 0;
 650:	4981                	li	s3,0
 652:	bd65                	j	50a <vprintf+0x60>
        putc(fd, c);
 654:	85d2                	mv	a1,s4
 656:	8556                	mv	a0,s5
 658:	00000097          	auipc	ra,0x0
 65c:	d86080e7          	jalr	-634(ra) # 3de <putc>
      state = 0;
 660:	4981                	li	s3,0
 662:	b565                	j	50a <vprintf+0x60>
        s = va_arg(ap, char*);
 664:	8b4e                	mv	s6,s3
      state = 0;
 666:	4981                	li	s3,0
 668:	b54d                	j	50a <vprintf+0x60>
    }
  }
}
 66a:	70e6                	ld	ra,120(sp)
 66c:	7446                	ld	s0,112(sp)
 66e:	74a6                	ld	s1,104(sp)
 670:	7906                	ld	s2,96(sp)
 672:	69e6                	ld	s3,88(sp)
 674:	6a46                	ld	s4,80(sp)
 676:	6aa6                	ld	s5,72(sp)
 678:	6b06                	ld	s6,64(sp)
 67a:	7be2                	ld	s7,56(sp)
 67c:	7c42                	ld	s8,48(sp)
 67e:	7ca2                	ld	s9,40(sp)
 680:	7d02                	ld	s10,32(sp)
 682:	6de2                	ld	s11,24(sp)
 684:	6109                	addi	sp,sp,128
 686:	8082                	ret

0000000000000688 <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 688:	715d                	addi	sp,sp,-80
 68a:	ec06                	sd	ra,24(sp)
 68c:	e822                	sd	s0,16(sp)
 68e:	1000                	addi	s0,sp,32
 690:	e010                	sd	a2,0(s0)
 692:	e414                	sd	a3,8(s0)
 694:	e818                	sd	a4,16(s0)
 696:	ec1c                	sd	a5,24(s0)
 698:	03043023          	sd	a6,32(s0)
 69c:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 6a0:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 6a4:	8622                	mv	a2,s0
 6a6:	00000097          	auipc	ra,0x0
 6aa:	e04080e7          	jalr	-508(ra) # 4aa <vprintf>
}
 6ae:	60e2                	ld	ra,24(sp)
 6b0:	6442                	ld	s0,16(sp)
 6b2:	6161                	addi	sp,sp,80
 6b4:	8082                	ret

00000000000006b6 <printf>:

void
printf(const char *fmt, ...)
{
 6b6:	711d                	addi	sp,sp,-96
 6b8:	ec06                	sd	ra,24(sp)
 6ba:	e822                	sd	s0,16(sp)
 6bc:	1000                	addi	s0,sp,32
 6be:	e40c                	sd	a1,8(s0)
 6c0:	e810                	sd	a2,16(s0)
 6c2:	ec14                	sd	a3,24(s0)
 6c4:	f018                	sd	a4,32(s0)
 6c6:	f41c                	sd	a5,40(s0)
 6c8:	03043823          	sd	a6,48(s0)
 6cc:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 6d0:	00840613          	addi	a2,s0,8
 6d4:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 6d8:	85aa                	mv	a1,a0
 6da:	4505                	li	a0,1
 6dc:	00000097          	auipc	ra,0x0
 6e0:	dce080e7          	jalr	-562(ra) # 4aa <vprintf>
}
 6e4:	60e2                	ld	ra,24(sp)
 6e6:	6442                	ld	s0,16(sp)
 6e8:	6125                	addi	sp,sp,96
 6ea:	8082                	ret

00000000000006ec <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 6ec:	1141                	addi	sp,sp,-16
 6ee:	e422                	sd	s0,8(sp)
 6f0:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
 6f2:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 6f6:	00001797          	auipc	a5,0x1
 6fa:	90a7b783          	ld	a5,-1782(a5) # 1000 <freep>
 6fe:	a805                	j	72e <free+0x42>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
 700:	4618                	lw	a4,8(a2)
 702:	9db9                	addw	a1,a1,a4
 704:	feb52c23          	sw	a1,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 708:	6398                	ld	a4,0(a5)
 70a:	6318                	ld	a4,0(a4)
 70c:	fee53823          	sd	a4,-16(a0)
 710:	a091                	j	754 <free+0x68>
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
 712:	ff852703          	lw	a4,-8(a0)
 716:	9e39                	addw	a2,a2,a4
 718:	c790                	sw	a2,8(a5)
    p->s.ptr = bp->s.ptr;
 71a:	ff053703          	ld	a4,-16(a0)
 71e:	e398                	sd	a4,0(a5)
 720:	a099                	j	766 <free+0x7a>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 722:	6398                	ld	a4,0(a5)
 724:	00e7e463          	bltu	a5,a4,72c <free+0x40>
 728:	00e6ea63          	bltu	a3,a4,73c <free+0x50>
{
 72c:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 72e:	fed7fae3          	bgeu	a5,a3,722 <free+0x36>
 732:	6398                	ld	a4,0(a5)
 734:	00e6e463          	bltu	a3,a4,73c <free+0x50>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 738:	fee7eae3          	bltu	a5,a4,72c <free+0x40>
  if(bp + bp->s.size == p->s.ptr){
 73c:	ff852583          	lw	a1,-8(a0)
 740:	6390                	ld	a2,0(a5)
 742:	02059713          	slli	a4,a1,0x20
 746:	9301                	srli	a4,a4,0x20
 748:	0712                	slli	a4,a4,0x4
 74a:	9736                	add	a4,a4,a3
 74c:	fae60ae3          	beq	a2,a4,700 <free+0x14>
    bp->s.ptr = p->s.ptr;
 750:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
 754:	4790                	lw	a2,8(a5)
 756:	02061713          	slli	a4,a2,0x20
 75a:	9301                	srli	a4,a4,0x20
 75c:	0712                	slli	a4,a4,0x4
 75e:	973e                	add	a4,a4,a5
 760:	fae689e3          	beq	a3,a4,712 <free+0x26>
  } else
    p->s.ptr = bp;
 764:	e394                	sd	a3,0(a5)
  freep = p;
 766:	00001717          	auipc	a4,0x1
 76a:	88f73d23          	sd	a5,-1894(a4) # 1000 <freep>
}
 76e:	6422                	ld	s0,8(sp)
 770:	0141                	addi	sp,sp,16
 772:	8082                	ret

0000000000000774 <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 774:	7139                	addi	sp,sp,-64
 776:	fc06                	sd	ra,56(sp)
 778:	f822                	sd	s0,48(sp)
 77a:	f426                	sd	s1,40(sp)
 77c:	f04a                	sd	s2,32(sp)
 77e:	ec4e                	sd	s3,24(sp)
 780:	e852                	sd	s4,16(sp)
 782:	e456                	sd	s5,8(sp)
 784:	e05a                	sd	s6,0(sp)
 786:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 788:	02051493          	slli	s1,a0,0x20
 78c:	9081                	srli	s1,s1,0x20
 78e:	04bd                	addi	s1,s1,15
 790:	8091                	srli	s1,s1,0x4
 792:	0014899b          	addiw	s3,s1,1
 796:	0485                	addi	s1,s1,1
  if((prevp = freep) == 0){
 798:	00001517          	auipc	a0,0x1
 79c:	86853503          	ld	a0,-1944(a0) # 1000 <freep>
 7a0:	c515                	beqz	a0,7cc <malloc+0x58>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 7a2:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 7a4:	4798                	lw	a4,8(a5)
 7a6:	02977f63          	bgeu	a4,s1,7e4 <malloc+0x70>
 7aa:	8a4e                	mv	s4,s3
 7ac:	0009871b          	sext.w	a4,s3
 7b0:	6685                	lui	a3,0x1
 7b2:	00d77363          	bgeu	a4,a3,7b8 <malloc+0x44>
 7b6:	6a05                	lui	s4,0x1
 7b8:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
 7bc:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
 7c0:	00001917          	auipc	s2,0x1
 7c4:	84090913          	addi	s2,s2,-1984 # 1000 <freep>
  if(p == (char*)-1)
 7c8:	5afd                	li	s5,-1
 7ca:	a88d                	j	83c <malloc+0xc8>
    base.s.ptr = freep = prevp = &base;
 7cc:	00001797          	auipc	a5,0x1
 7d0:	84478793          	addi	a5,a5,-1980 # 1010 <base>
 7d4:	00001717          	auipc	a4,0x1
 7d8:	82f73623          	sd	a5,-2004(a4) # 1000 <freep>
 7dc:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 7de:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
 7e2:	b7e1                	j	7aa <malloc+0x36>
      if(p->s.size == nunits)
 7e4:	02e48b63          	beq	s1,a4,81a <malloc+0xa6>
        p->s.size -= nunits;
 7e8:	4137073b          	subw	a4,a4,s3
 7ec:	c798                	sw	a4,8(a5)
        p += p->s.size;
 7ee:	1702                	slli	a4,a4,0x20
 7f0:	9301                	srli	a4,a4,0x20
 7f2:	0712                	slli	a4,a4,0x4
 7f4:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 7f6:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 7fa:	00001717          	auipc	a4,0x1
 7fe:	80a73323          	sd	a0,-2042(a4) # 1000 <freep>
      return (void*)(p + 1);
 802:	01078513          	addi	a0,a5,16
      if((p = morecore(nunits)) == 0)
        return 0;
  }
}
 806:	70e2                	ld	ra,56(sp)
 808:	7442                	ld	s0,48(sp)
 80a:	74a2                	ld	s1,40(sp)
 80c:	7902                	ld	s2,32(sp)
 80e:	69e2                	ld	s3,24(sp)
 810:	6a42                	ld	s4,16(sp)
 812:	6aa2                	ld	s5,8(sp)
 814:	6b02                	ld	s6,0(sp)
 816:	6121                	addi	sp,sp,64
 818:	8082                	ret
        prevp->s.ptr = p->s.ptr;
 81a:	6398                	ld	a4,0(a5)
 81c:	e118                	sd	a4,0(a0)
 81e:	bff1                	j	7fa <malloc+0x86>
  hp->s.size = nu;
 820:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
 824:	0541                	addi	a0,a0,16
 826:	00000097          	auipc	ra,0x0
 82a:	ec6080e7          	jalr	-314(ra) # 6ec <free>
  return freep;
 82e:	00093503          	ld	a0,0(s2)
      if((p = morecore(nunits)) == 0)
 832:	d971                	beqz	a0,806 <malloc+0x92>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 834:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 836:	4798                	lw	a4,8(a5)
 838:	fa9776e3          	bgeu	a4,s1,7e4 <malloc+0x70>
    if(p == freep)
 83c:	00093703          	ld	a4,0(s2)
 840:	853e                	mv	a0,a5
 842:	fef719e3          	bne	a4,a5,834 <malloc+0xc0>
  p = sbrk(nu * sizeof(Header));
 846:	8552                	mv	a0,s4
 848:	00000097          	auipc	ra,0x0
 84c:	b76080e7          	jalr	-1162(ra) # 3be <sbrk>
  if(p == (char*)-1)
 850:	fd5518e3          	bne	a0,s5,820 <malloc+0xac>
        return 0;
 854:	4501                	li	a0,0
 856:	bf45                	j	806 <malloc+0x92>
