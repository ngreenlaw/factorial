TITLE Program 6B Recursive Combinatorics by Nathan Greenlaw

; Author: Nathan Greenlaw
; Course/Project ID: CS 271, Assignment 6B		Date: 3/19/2017
; Description: Display your name and program title,
; generate a number n in [3,12] and r in [1,n], get answer from user 
; calculate the solution using factorials, display the answer
; tell the user if they are right or wrong, ask if they want another problem


INCLUDE Irvine32.inc

COMMENT !
	
	
	MACROS to be used in program


	!


displayStringMacro MACRO word
	push	edx
	mov		edx, OFFSET word
	call	WriteString
	pop		edx
ENDM

readStringMacro MACRO word
	push	ecx
	push	edx
	mov		edx, OFFSET word
	mov		ecx, SIZEOF word
	call	ReadString
	pop		edx
	pop		ecx
ENDM

randomGenMacro MACRO hi,lo,target
	push	eax
	
	mov		eax,hi
	sub		eax,lo
	inc		eax
	call	RandomRange
	add		eax,lo

	mov		[target],eax
	call	writeDec

	pop		eax
ENDM



COMMENT !
	
	
	Variables to be used in the program


	!


.data 

;Variables to store data

userAnswer DWORD 10 DUP(0);BYTE 10 DUP(0) ; the user entered string number for nCr
userAnswerNumber DWORD 0 ; the user entered number for nCr
answer DWORD ?	; actual answer for nCr
n DWORD 10			; set of n items
r DWORD 10			; number of combinations of r items from set of n items

nFact DWORD ?	;n factorial
rFact DWORD ?	;r factorial
nMinusrFact DWORD ?	;n-r factorial

;Constant variables

NMIN equ 3		; constant lower limit for n
NMAX equ 12		; constant upper limit for r

RMIN	equ	1		; constant lower limit for random
;RMAX	DWORD 100	; constant upper limit for random

;Program flow variables

intro_1	BYTE "Recursive Combinatorics by Nathan Greenlaw",0;
intro_2 BYTE "I'll give you a combinations problem. You enter your answer, and I'll let you know if you're right.",0

invalidInputString BYTE "Invalid input.",0

middle_1 BYTE "Number of elements in the set: ",0
middle_2 BYTE "Number of elements to choose from: ",0
middle_3 BYTE "How many ways can you choose? ",0

results_1 BYTE "There are ",0			; answer inserted here
results_2 BYTE " combinations of ",0	; r inserted here
results_3 BYTE " from a set of ",0		; n inserted here

answer_eval_1 BYTE "You are correct!",0 ; if the answer is correct
answer_eval_2 BYTE "You are incorrect.",0 ; if the answer is incorrect

finish_1 BYTE "Another Problem? (y/n): ",0 ; ask for another problem
finish_2 BYTE "Ok, goodbye."	; if user decides not to do another problem



COMMENT !
	
	
	Start the actual process of the code


	!

.code

main proc

;Start program
	call	Randomize

	call	intro
	call	Crlf

problem:
;Randomly select n and r and display the problem to the user
	push	OFFSET n
	push	OFFSET r

	call	displayProblem

;get User data and validate input
	mov		userAnswerNumber,0
	push	OFFSET userAnswer
	push	OFFSET userAnswerNumber

	call	getUserData

;Calculate answer and check to see if correct
	push	OFFSET answer ;28
	push	OFFSET	n ;24
	push	OFFSET	r ;20
	push	OFFSET	nFact; 16
	push	OFFSET	rFact ;12
	push	OFFSET	nMinusRFact ; 8

	call	combination

;display results

	displayStringMacro results_1
	mov		eax,answer
	call	WriteDec
	displayStringMacro results_2
	mov		eax,r
	call	WriteDec
	displayStringMacro results_3
	mov		eax,n
	call	WriteDec
	call	crlf

;check if answer is correct
	push	userAnswerNumber
	push	answer

	call	answerCheck

;check to see if looping to do another problem

	call	anotherProblem
	cmp		eax,1
	je		problem

;End Program
	call	finishProgram

	exit
main endp



COMMENT !
	
	
	The procs used in the program


	!

COMMENT !
	intro

	Displays the introduction to the user.
	Receives: intro_1, intro_2
	Returns: nothing
	!

intro PROC
	;Start program
	displayStringMacro intro_1
	call	Crlf

	displayStringMacro intro_2
	call	Crlf
	call	Crlf

	ret
intro ENDP

COMMENT !
	displayProblem

	Displays the problem to the user
	Receives: n,r
	Returns: nothing
	!

displayProblem PROC
	;displays the problem for the user

	push	ebp
	mov		ebp,esp
	mov		ebx,[ebp+12]
	mov		ecx,[ebp+8]

	displayStringMacro middle_1
	randomGenMacro NMAX,NMIN,ebx
	call	Crlf

	displayStringMacro middle_2
	randomGenMacro [ebx],RMIN,ecx
	call	Crlf

	pop		ebp
	ret		8
displayProblem ENDP
	
COMMENT !
	getUserData

	Gets data from the user and validates the input.
	Receives: userAnswer, userAnswerNumber
	Returns: nothing
	!

getUserData PROC
;Get user input
	push	ebp
	mov		ebp,esp
	mov		ebx,[ebp+12] ; string
	mov		edx,[ebp+8] ; number
	mov		esi, ebx	;OFFSET userAnswer

	;Start program
getData:
	mov		ebx,[ebp+12] ; string
	mov		esi, ebx

	call	Crlf
	displayStringMacro middle_3
	readStringMacro userAnswer

	push	eax
	INVOKE Str_length, ADDR userAnswer
	mov		ecx, eax
	pop		eax

	cmp		ecx,8
	jg		incorrectInput

	cld
	jmp		validate

incorrectInput:
;Display that input is incorrect
	displayStringMacro invalidInputString
	jmp		getData

validate:
	mov		ebx,[ebp+8]
	mov		eax,[ebx]
	mov		ebx,10d
	mul		ebx
	mov		ebx,[ebp+8]
	mov		[ebx],eax
	lodsb
	
;Validate the input for 0
	cmp		al, 48d
	jl		incorrectInput
	cmp		al, 57d
	jg		incorrectInput
	jmp		valid
	

valid:
	sub		al,48
	mov		ebx,[ebp+8]
	add		[ebx],al

	loop	validate

	pop		ebp
	ret		4
getUserData ENDP

COMMENT !
	factorial

	Calculates the factorial of a given number, code from pg305 of irvine library
	Receives: a number
	Returns: eax = factorial
	!

factorial PROC
	push	ebp
	mov		ebp,esp
	mov		eax,[ebp+8]
	cmp		eax,0
	ja		L1
	mov		eax,1
	jmp		L2

L1:
	dec		eax
	push	eax
	call	factorial

returnFact:
	mov		ebx,[ebp+8]
	mul		ebx

L2:
	pop		ebp
	ret		4

factorial ENDP

COMMENT !
	combination

	Calculates the combination
	Receives: n,r,answer, nFact, rFact, nMinusrFact
	Returns: answer = correct answer
	!

combination PROC
	push	ebp
	mov		ebp,esp

	;calculate n factorial

	mov		ebx, [ebp+24];n
	push	[ebx]
	call	factorial
	mov		ebx,[ebp+16]
	mov		[ebx],eax ;nFact,eax 

	;calculate r factorial
	mov		ebx, [ebp+20];r
	push	[ebx]
	call	factorial
	mov		ebx,[ebp+12]
	mov		[ebx],eax ;rFact,eax 

	;calculate n-r factorial
	mov		ecx, [ebp+24];n
	mov		ebx,[ecx]
	mov		edx,[ebp+20]
	mov		eax, [edx];r

	sub		ebx,eax
	push	ebx
	call	factorial
	mov		ebx,[ebp+8];nMinusrFact,eax
	mov		[ebx],eax

	;Calculate the actual answer

	mov		ebx, [ebp+12];rFact
	mov		eax,[ebx]
	mov		ecx, [ebp+8];nMinusrFact
	mov		ebx,[ecx]

	mul		ebx
	mov		ebx,eax

	mov		ecx, [ebp+16];nFact
	mov		eax,[ecx]

	div		ebx

	mov		ecx,[ebp+28];answer,eax
	mov		[ecx],eax	

	pop		ebp
	ret		24
combination ENDP

COMMENT !
	answerCheck

	Checks if the input answer is the same as the correct one
	Receives: userAnswerNumber, answer
	Returns: nothing
	!

answerCheck PROC
	push	ebp
	mov		ebp,esp
	mov		eax, [ebp+8] ;answer
	mov		ebx, [ebp+12] ;userAnswerNumber
	;call	WriteDec

	cmp		ebx,eax
	je		correct

incorrect:
	displayStringMacro	answer_eval_2
	call	Crlf
	jmp		theEnd

correct:
	displayStringMacro	answer_eval_1
	call	Crlf

theEnd:
	pop		ebp
	ret		4
answerCheck ENDP

COMMENT !
	anotherProblem

	Asks if the user wants another problem
	Receives: Nothing
	Returns: eax = 1 for yes or 0 for no
	!

anotherProblem PROC

getInput:
	call	Crlf
	displayStringMacro finish_1
	call	readChar
	call	WriteChar
	call	Crlf

	jo		invalid
	jmp		validate

invalid:
	displayStringMacro invalidInputString
	jmp		getInput

validate:
	cmp		al, 121
	je		yes
	cmp		al, 89
	je		yes

	cmp		al, 78
	je		no
	cmp		al, 110
	je		no

	jmp invalid

yes:
	mov		eax,1
	jmp		fin

no:
	mov		eax,0
	jmp		fin

fin:
	ret
anotherProblem ENDP

COMMENT !
	finishProgram

	Ends the program and displays message.
	Receives: Nothing
	Returns: Nothing
	!

finishProgram PROC
;End the program
	call	Crlf
	displayStringMacro finish_2
	call	Crlf
	ret
finishProgram ENDP

end main