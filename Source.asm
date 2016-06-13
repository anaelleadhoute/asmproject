.486
.model flat, stdcall
option casemap :none

include \masm32\include\windows.inc
include \masm32\include\kernel32.inc
include \masm32\include\user32.inc
include \masm32\include\msvcrt.inc
includelib msvcrt.lib
include drd.inc
includelib drd.lib

.data
    ;consts
	bgfile BYTE "dinoproject/white.bmp", 0
	bgimage Img<0,0,0,0>
	dinofile BYTE "dinoproject/frames.bmp" , 0
	dinoimage Img<0,0,0,0> 
	frame1file BYTE "dinoproject/frame1.bmp", 0
	frame1img Img <0,0,0,0>
	frame2file BYTE "dinoproject/frame2.bmp", 0
	frame2img Img <0,0,0,0>
	cactusfile BYTE "dinoproject/cactus.bmp", 0
	cactusimg Img<0,0,0,0>

	space BYTE 20h
	floory DWORD 8000
	vdown DWORD 300
	gravity DWORD 1
	dinox DWORD 50
	jumpv DWORD 500
	;state
	dinoy DWORD 8000
	dinov DWORD 200
	cactusY DWORD 600
	cactusX0 dword 11200
	cactusX DWORD 10000
	limitX Dword 900
	switch BYTE 0
	cactusV DWORD 10
	framecounter DWORD 0
	frameflag DWORD 0


.code
drd_imageLoadFile PROTO filename:DWORD, pimg:DWORD



changeimg PROC
	pusha
	cmp switch, 1
	jne frame1
	frame1:
	invoke drd_imageLoadFile, offset frame2file, offset frame2img
	popa
	ret 
	changeimg ENDP

collisioncheck PROC 

 ;dinoimage.iwidth
 ;dinoimage.iheight
 ;cactusimg.iwidth
 ;cactusimg.iheight
 ;dinox
 ;dinoy
 ;cactusX
 ;cactusY
	mov eax, cactusX
	shr eax, 4
	sub eax, dinox
	cmp eax, frame1img.iwidth
	jge nocollision
	neg eax
	cmp eax, cactusimg.iwidth
	jge nocollision

	mov eax, dinoy
	shr eax, 4
	sub eax, cactusY
	neg eax
	cmp eax, frame1img.iheight
	jge nocollision
	neg eax
	cmp eax, cactusimg.iheight
	jge nocollision

	mov eax, 1
	ret

	nocollision:
	xor eax, eax
	ret

	; bool function 1 is true and 0 false

collisioncheck ENDP

cactus PROC 
	push eax
	push ebx
	mov ebx, cactusV
	mov eax, cactusX
	cmp eax, limitX
	sub cactusX, ebx 
	jne nolimit
	mov eax, cactusX0
	mov cactusX, eax
	nolimit:

	;int y = 5
	;int x = y
	;x += 5

	pop eax
	pop ebx
	ret
cactus ENDP

jump PROC
	push eax
	invoke GetAsyncKeyState, space
	test eax, 1
 	jz isnotpressed
	mov eax, dinoy
	cmp eax, floory
	jnz isnotpressed

	mov eax, dinov ;v = gt, y = vt v = vefes + gt
	sub eax, jumpv
	mov dinov, eax

	isnotpressed:
	pop eax
	ret
jump ENDP



gravityfunc PROC
	push eax
	push ebx
	push edx

   	mov eax, dinov
	mov ebx, 20
	cdq
	idiv ebx 
	mov ebx, dinoy
	add eax, ebx
	mov dinoy, eax
	
	mov eax, dinov
	mov ebx, gravity
	add eax, ebx
	mov dinov, eax
	
	pop edx
	pop ebx
	pop eax

	ret
gravityfunc ENDP

floorcheck PROC
    push eax 
	mov eax, floory
	cmp eax, dinoy
	jge nofloor
	mov dinov, 0
	mov dinoy, eax
	nofloor:

	pop eax
	ret 
floorcheck ENDP

update PROC
    push ebx
	push eax
	inc framecounter
	test framecounter, 63 ; 15 = 1111, 16 = 10000
	jnz sameframe
	xor frameflag, 1
	sameframe:
	call gravityfunc
	call floorcheck
	call jump
	call collisioncheck
	test eax, eax ; return eax
	jz zerocollision
	mov ebx, 0
	div ebx


	zerocollision:
	pop eax
	pop ebx
	ret

update ENDP 

	

draw PROC
	push eax
	push ebx

	invoke drd_imageDraw, offset bgimage, 0, 0 

	mov eax, cactusX
	shr eax, 4
	invoke drd_imageDraw, offset cactusimg, eax, cactusY 

	mov eax, dinoy
	shr eax, 4
	test frameflag, 1
	jnz chgframe
	invoke drd_imageDraw, offset frame2img, dinox, eax 
	jmp goaway
	chgframe:
	invoke drd_imageDraw, offset frame1img, dinox, eax 
	goaway:
	invoke drd_processMessages
 	invoke drd_flip
	pop eax
	pop ebx
	ret
	draw ENDP




main PROC
	push eax
	push ebx
	invoke drd_init, 1000, 1000, INIT_WINDOW
	invoke drd_imageLoadFile, offset dinofile, offset dinoimage
	invoke drd_imageLoadFile, offset bgfile, offset bgimage
	invoke drd_imageLoadFile, offset frame1file, offset frame1img
	invoke drd_imageLoadFile, offset frame2file, offset frame2img
	invoke drd_imageLoadFile, offset cactusfile, offset cactusimg
	invoke drd_processMessages
 	invoke drd_flip 

	
	main_loop:
     
	call draw
	call update
	call cactus
	jmp main_loop	

	pop ebx
	pop eax
main ENDP
end main
