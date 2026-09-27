# Jacob Weikum, dal796652
# this mergesort works by filling out an array of 2^n and then splitting it up using a bottom up approach 
# and then merging it together using an in place merge. It splits up the input into two sections, with a start, middle,
# and end. The second array starts at the middle index. If the first value is less than the second value, leave in place,
# otherwise push everything from the first start to second start by 1 and then fill in the gap with the smaller, second value.

.data
list: .space 128 # space that stores 32 integers
enterLength: .asciiz "Please enter the number of entries "
enterNumber: .asciiz "please enter a number "


.text
# load list into $s0
la $s0, list

# print out enterLength
li $v0, 4
la $a0, enterLength
syscall

# take user input for length
li $v0, 5
syscall
add $s1, $v0, $zero # save result to $s1

# use $t0 as an index/itterator 
li $t0, 0

# fill up the list
fillout:
	beq $t0, $s1, mergesort # once list is filled out, begin mergesort

	# print out enterNumber
	li $v0, 4
	la $a0, enterNumber
	syscall
	
	#take in number
	li $v0, 5
	syscall
	
	#add to list
	sll $t1, $t0, 2 # multiply index by 2 to find offset
	add $t1, $s0, $t1 # add offset to list address
	sw $v0, ($t1) # save input to list
	addi $t0, $t0, 1 # increment index
	
	j fillout
	
# do merge sort using bottom up approach
mergesort:
	li $t0 1 # represents current bounds of merging
	
	loop:
		# once the current boundry is greater than length, mergesort is done
		slt $t9 $t0 $s1
		beq $t9 0 printout 
		
		li $t1 0 # represents start index
		
		subloop:
			#  if start is greater than length, mergesort is done at the current bounds
			slt $t9 $t1 $s1
			beq $t9 0 subloopEnd 
			
			# fill out merge arguments
			add $a0 $t1 $zero # start index
			add $a1 $a0 $t0 # mid = start index + bound 
			add $a2 $a1 $t0 # end = start index + 2*bound = mid + bound
		
			jal merge
			
			# increment start by 2*bound
			add $t1 $t1 $t0
			add $t1 $t1 $t0
			
			j subloop
			
		# double the boundry
		subloopEnd:
			sll $t0 $t0 1
			j loop 
			

# merge contents together in list, splitting it into a start, middle, and end where start to middle is compared to middle to end
merge:
	# $a0 start index
	# $a1 middle index
	# $a2 end index
	add $t2 $a1 $zero  # use $t2 as the start index for the second half which starts at middle index
	li $t3 0 # use $t3 as incrementer 
	
	mergeLoop:
		# if start index is greater than or equal to middle, than the section is sorted
		slt $t9 $a0 $a1 
		beq $t9 0 return
		# if start index for the second half is greater than or equal to end, than the section is sorted
		slt $t9 $t2 $a2
		beq $t9 0 return
		
		# get the values at start indices
		sll $t4 $a0 2
		sll $t5 $t2 2
		add $t4 $t4 $s0
		add $t5 $t5 $s0
		lw $t4 ($t4) # value at start 
		lw $t5 ($t5) # value at start for the second half

		# if array[lower start] < array[upper start] then continue, otherwise branch to pushUp
		slt $t9 $t4 $t5
		beq $t9 0 pushUp
		
		# values are correctly in place, increment first start index
		addi $a0 $a0 1
		
		j mergeLoop
		
	# push all contents from the first start to the second start and 
	# then put the lower value from the second start at the first start index
	pushUp:
		# swap via array[n] =  array[n-1]
		add $t6 $t2 $zero
		sll $t6 $t6 2
		add $t6 $t6 $s0 # second starting point address
		sll $t7 $a0 2 
		add $t7 $t7 $s0 # lower address bound, first starting point
		
		# shift all values up
		swap:
			beq $t6 $t7 swapEnd # stop once the value at start index has swapped with started index + 1
			lw $t4 -4($t6) # load lower address value
			sw $t4 ($t6) # save lower address value to upper index
			subi $t6 $t6 4
			j swap
		
		swapEnd:
			# put the lower value at the inital lower start index
			addi $t8 $t8 4
			sw $t5 ($t7)
			
			# increment to account for movement
			add $a0 $a0 1 # first start
			add $a1 $a1 1 # middle
			add $t2 $t2 1 # second start
			
			j mergeLoop
		
	return:
		jr $ra

# print out contents of list
printout:
	#use $t0 as an index/itterator
	li $t0, 0
	
	print:
		beq $t0 $s1 end # once list is printed out, end
	
		sll $t1, $t0, 2 # multiply index by 2 to find offset
		add $t1, $s0, $t1 # add offset to list address
		lw $a0, ($t1) # load value at index using address
		li $v0, 1 # print out value
		syscall 
	
		# add space for legibility 
		li $a0, 32
  		li $v0, 11 
  		syscall
	
		addi $t0, $t0, 1 # increment index
		
		j print
	
# end program
end:
	li $v0 10
	syscall
	
