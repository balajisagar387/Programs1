# 27. Remove Element
""" Given an integer array nums and an integer val, remove all occurrences of val in nums in-place. The order of the elements may be changed. Then return the number of elements in nums which are not equal to val."""

# Approach 1: Two Pointers (Front to Back)

def remove_element(nums, val):
    """
    Removes all occurrences of val in nums in-place and returns the new length.
    
    Parameters:
    nums (List[int]): The input array from which to remove elements.
    val (int): The value to be removed from the array.
    
    Returns:
    int: The number of elements in nums that are not equal to val.
    """
    
    # pointer for the position of the next non-val element
    k = 0
    print(f"Initial nums: {nums}, val: {val}")
    
    for i in range(len(nums)):
        if nums[i] != val:
            nums[k] = nums[i]
            k += 1
            
    return k

nums = [0,1,2,2,3,0,4,2]
val = 2
k = remove_element(nums, val)
print("k =", k)
print("nums =", nums[:k], "+ remaining ignored Approach 1: Two Pointers (Front to Back)")

#Approach 2: Swap with Last (Order Not Important)

def remove_element_swap(nums, val):
    """
    Removes all occurrences of val in nums in-place by swapping with the last element.
    
    Parameters:
    nums (List[int]): The input array from which to remove elements.
    val (int): The value to be removed from the array.
    
    Returns:
    int: The number of elements in nums that are not equal to val.
    """
    
    # pointer for the current element
    i = 0
    # pointer for the last element
    n = len(nums)
    print(f"Initial nums: {nums}, val: {val}")
    
    while i < n:
        if nums[i] == val:
            nums[i] = nums[n - 1]
            n -= 1
        else:
            i += 1
            
    return n

k1 = remove_element_swap(nums, val)
print("k =", k)
print("nums =", nums[:k1], "+ remaining ignored Approach 2: Swap with Last (Order Not Important)")

print("Both approaches are O(n) time and O(1) space, but Approach 1 is simpler and more intuitive.")