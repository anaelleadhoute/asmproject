.486
.model flat, stdcall
option casemap :none

include \masm32\include\user32.inc
include drd.inc
includelib drd.lib

.data
    ;consts
	bgfile BYTE "dinoproject/white.bmp", 0
	bgimage Img<0,0,0,0>

	frame1file BYTE "dinoproject/frame1.bmp", 0
	frame1img Img <0,0,0,0>

	frame2file BYTE "dinoproject/frame2.bmp", 0
	frame2img Img <0,0,0,0>

	dinojmpfile BYTE "dinoproject/jumpdino.bmp", 0
	dinoimg Img <0,0,0,0>

	cactusfile BYTE "dinoproject/cactus.bmp", 0
	cactusimg Img<0,0,0,0>

	looserfile BYTE "dinoproject/looser.bmp", 0
	looserimg Img<0,0,0,0>

	tziporfile BYTE "dinoproject/tzipor.bmp", 0
	tziporimg Img<0,0,0,0>

	floorfile BYTE "dinoproject/floor.bmp", 0
	floorimg Img<0,0,0,0>

	cloudfile BYTE "dinoproject/realcloud.bmp", 0
	cloudimg Img<0,0,0,0>

	starbucksfile BYTE "dinoproject/starbucks.bmp", 0
	starbucksimg Img<0,0,0,0>

	lcg_x DWORD 0

	space BYTE 20h
	floory DWORD 9500
	vdown DWORD 300
	gravity DWORD 1
	dinox DWORD 300
	jumpv DWORD 400
	;state
	dinoy DWORD 8000
	dinov DWORD 200

	cactusY DWORD 650
	cactusX0 dword 16000
	cactusX DWORD 10000
	limitXcactus Dword 4000

	white DWORD 16777215

	tziporY DWORD 1
	tziporX DWORD 100
	tziporV DWORD 1
	tziporX0 DWORD 50
	limitXtzipor DWORD 16000

	switch BYTE 0
	cactusV DWORD 8
	framecounter DWORD 0
	frameflag DWORD 0
	cloudflag DWORD 0

	collisionflag DWORD 0




.code
drd_imageLoadFile PROTO filename:DWORD, pimg:DWORD

lcg_rand PROC
    push edx
	mov eax, lcg_x
	mov edx, 214013 
	mul edx
	add eax, 2531011 
	mov lcg_x, eax
	pop edx
	ret
lcg_rand ENDP 

	 ;11111111
	        ;1
	;100000000		

 birds PROC
	push eax
	push ebx
	mov ebx, tziporV
	mov eax, tziporX
	add tziporX, ebx 
	cmp eax, limitXtzipor
	jne nolimit
	mov eax, tziporX0
	mov tziporX, eax
	nolimit:
	pop eax
	pop ebx

	ret 
	birds ENDP

collisioncheck PROC 
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
	mov collisionflag, 1
	ret

	nocollision:
	xor eax, eax
	ret
collisioncheck ENDP

cactus PROC 
	push eax
	push ebx
	mov ebx, cactusV
	mov eax, cactusX
	sub cactusX, ebx 
	cmp eax, limitXcactus
	jg nolimit
	mov eax, cactusX0
	mov cactusX, eax
	nolimit:
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
	sub eax, jumpv ;;;why
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
	mov ebx, 13 ;why
	cdq
	idiv ebx 
	mov ebx, dinoy
	add eax, ebx  ; dinoy + dinov\13
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
	mov eax, 1
	nofloor:

	pop eax
	ret 
floorcheck ENDP

update PROC
    push ebx
	push eax
	call cactus
	call birds
	mov eax, dinoy
	cmp eax, floory
	jne sameframe
	inc framecounter
	test framecounter, 63 ; 15 = 1111, 16 = 10000
	jnz sameframe
	xor frameflag, 1
	test framecounter, 255
	jnz setcloudflag
	sameframe:
	call gravityfunc
	call floorcheck
	call jump
	call collisioncheck
	test eax, eax ; return eax
	jz zerocollision
	invoke drd_imageDraw, offset looserimg, 100, 100
	setcloudflag:
	mov cloudflag, 1




	zerocollision:
	pop eax
	pop ebx
	ret

update ENDP 

	

draw PROC
	push eax
	push ebx


	invoke drd_imageDraw, offset bgimage, 0, 0 

	invoke drd_imageDraw, offset floorimg, 300, 730

	;invoke drd_imageDraw, offset starbucksimg, 300, 100


	mov eax, cactusX
	shr eax, 4
	invoke drd_imageDraw, offset cactusimg, eax, cactusY 
	invoke drd_imageSetTransparent, offset cactusimg, white

	mov eax, tziporX
	shr eax, 4
	invoke drd_imageDraw, offset tziporimg, eax, tziporY 

	mov eax, dinoy
	shr eax, 4
	cmp frameflag, 1
	jnz chgframe
	invoke drd_imageDraw, offset frame2img, dinox, eax 
	invoke drd_imageSetTransparent, offset frame2img, white
	jmp goaway
	chgframe:
	invoke drd_imageDraw, offset frame1img, dinox, eax 
	invoke drd_imageSetTransparent, offset frame1img, white
	goaway:
	mov eax, dinoy
	cmp eax, floory 
	je nojumpimg
	mov eax, dinoy
	;invoke drd_imageDraw, offset dinoimg, dinox, eax 
	nojumpimg:

	invoke drd_imageDraw, offset cloudimg, 800, 200
	invoke drd_imageDraw, offset cloudimg, 700, 500
	cmp collisionflag, 1
	jnz nomessage
	invoke drd_imageDraw, offset looserimg, 0, 0
	nomessage:


	invoke drd_processMessages
 	invoke drd_flip

	

	pop eax
	pop ebx
	ret
	draw ENDP




main PROC
	push eax
	push ebx
	invoke drd_init, 1500, 1500, INIT_WINDOW
	invoke drd_imageLoadFile, offset bgfile, offset bgimage
	invoke drd_imageLoadFile, offset frame1file, offset frame1img
	invoke drd_imageLoadFile, offset frame2file, offset frame2img
	invoke drd_imageLoadFile, offset cactusfile, offset cactusimg
	invoke drd_imageLoadFile, offset looserfile, offset looserimg
	invoke drd_imageLoadFile, offset tziporfile, offset tziporimg
	invoke drd_imageLoadFile, offset floorfile, offset floorimg
	invoke drd_imageLoadFile, offset dinojmpfile, offset dinoimg
	invoke drd_imageLoadFile, offset cloudfile, offset cloudimg
	invoke drd_imageLoadFile, offset starbucksfile, offset starbucksimg

	
	main_loop:
     
	call draw
	call update
	jmp main_loop	

	pop ebx
	pop eax
main ENDP
end main
