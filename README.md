# Makefile
## 1. Makefile là gì?
⦁	Makefile là file cấu hình được dùng bởi lệnh `make`, giúp tự động hóa quá trình biên dịch mã nguồn.

## 2. Cấu trúc cơ bản của một Makefile
```make
target: dependencies
<TAB>command
```
__Lưu ý:__ _Dòng lệnh sau target phải bắt đầu bằng một tab (không phải dấu cách!)._

## 3. Ví dụ đơn giản
```make
program: lib1.c lib2.c main.c
    gcc -c main.c -o main.o
    gcc -c lib1.c -o lib1.o
    gcc -c lib2.c -o lib2.o
    gcc lib1.o lib2.o main.o -o program
```
- Makefile này sẽ hoạt động như sao:
    - targer là program
    - dependencies: lib1.c lib2.c main.c

--> có nghĩa là:
- Để build được target (program) thì chúng ta cần những dependency kia
- Khi một trong những file trong dependencies thay đổi nội dung thì target sẽ đc chạy
## 4. Tự động hóa với makefile
### 4.1. Khi chúng ta chỉ thay đổi main.c, trigger build thì nó sẽ build lại file main.c và cả 2 file lib gây tốn thời gian do đó chúng ta tách ra như thế này:
```make

program: lib1.o lib2.o main.o
    gcc lib1.o lib2.o main.o -o program

lib1.o: lib1.c
    gcc -c lib1.c -o lib1.o

lib2.o: lib2.o
    gcc -c lib2.c -o lib2.o

main.0: main.c
    gcc -c main.c -o main.o

```
- lúc này program sẽ dependency lib1.o lib2.o main.o (chứ không phải các file .c)
- mỗi file .o sẽ được tạo ra từ các file .c --> khi thôi đổi file.c nào thì file.o sẽ được build lại, chứ không phải build lại tất cả --> chúng ta sẽ tiết kiệm được khá nhiều thòi gian

### 4.2. Makefile ở trên cũng còn nhược điểm, trong project của chúng ta chỉ có 3 file .c thôi, thì cũng ta viết nổi, chứ project có 10000 file.c là không viết nổi luôn
```make
program: lib1.o lib2.o main.o
 	gcc lib1.o lib2.o main.o -o program

%.o: %.c
    gcc -c $^ -o $@
```
- `$^` : là danh sách dependencies
- `$@` : là targer
### 4.3. Chúng ta có thể print log để debug trong Makefile
```make
program: lib1.o lib2.o main.o
 	gcc lib1.o lib2.o main.o -o program

%.o: %.c
    $(info Dang build @^ thanh $@)
 	gcc -c $^ -o $@
```
- sử dụng `$(info ...)` để in information (ngoài ra chúng ta có thể sử dụng error, debug...)

### 4.4. Trong dependencies của `program` vẫn chưa tối ưu
```make
SRCS=$(wildcard *.c)
OBJS=$(SRCS:.c=.o)
program: $(OBJS)
 	gcc $(OBJS) -o $@

%.o: %.c
    $(info Dang build $^ thanh $@)
 	gcc -c $^ -o $@
debug:
    $(info sources: $(SRCS))
    $(info objects: $(OBJS))
```
- `$(wildcard *.c)` tìm tất cả các file `.c` trong thư mục hiện tại.
- Gán danh sách đó cho biến `SRCS`.
- `$(SRCS:.c=.o)` chuyễn `lib1.c lib2.c main.c` thành `lib1.o lib2.o main.o`

```bash
D:\Temp_Dir\c_sample> make debug
sources: lib1.c lib2.c main.c
objects: lib1.o lib2.o main.o
```
### 4.5. Với makefile trên thì khi chúng ta thay đổi nội dung file.h thì nó không rebuild
```make
CC=gcc
SRCS=$(wildcard *.c)
OBJS=$(SRCS:.c=.o)
FLAG=-MMD
program: $(OBJS)
	$(info link all object files to $@)
	$(CC) $(OBJS) -o $@
%.o: %.c
	$(info build $< to $@)
	$(CC) -c $(FLAG) $< -o $@
debug:
	$(info sources: $(SRCS))
	$(info objects: $(OBJS))

clear: 
	rm *.o *.exe
-include *.d
```
- Sử dụng `-MMD` để `gcc` tạo ra những file.d trong file.d đó nó sẽ liệt kê các file cần thiết cho quá trình biên dịch của file đó. VD ta có một `main.d`
```bash
PS D:\Temp_Dir\c_sample> cat main.d
main.o: main.c lib2.h lib1.h

PS D:\Temp_Dir\c_sample> cat lib1.d
lib1.o: lib1.c
```
- trong `main.c` có `#include "lib2.h"` trong lib2.h của `#include "lib1.h"` do đó depedencies của `main.o` là `main.c`, `lib2.h` và `lib1.h`
- trong `lib1.c` không có include thư viện nào cả, nên nó chỉ có depedency một file `lib1.c' thôi
- Cuối cùng là sử dụng `-include *.d` để thêm tất cả các file.d vào khi chạy make
