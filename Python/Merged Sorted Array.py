# 88 array merging, two-pointer techniques, and in-place modification
# Approach 2: Merge from the End (Optimal & In-Place)

def merge(nums1, m, nums2, n):

    """
     Merges nums2 into nums1 in-place so that nums1 becomes a single
     sorted array. Both nums1 and nums2 are sorted initially.

     Parameters:
     nums1 (List[int]): First sorted array with size m + n.
                     The first m elements are valid, and the rest are zeros.
     m (int): Number of valid elements in nums1.
     nums2 (List[int]): Second sorted array with n elements.
     n (int): Number of elements in nums2.
    
    """

    # pointers
    p1 = m - 1 # last valid index in nums1
    p2 = n - 1 # last index in nums2
    p = m + n - 1 # last position in nums1 to fill

    # compare from the end and fill num1 backwards
    while p1 >= 0 and p2 >= 0:
        if nums1[p1] > nums2[p2]:
            nums1[p] = nums1[p1]
            p1 -= 1

        else :
            nums1[p] = nums2[p2]
            p2 -= 1

        p -= 1
    
    while p2 >=0 :
        nums1[p] = nums2[p2]
        p -= 1
        p2 -= 1




nums1 = [1, 2, 3, 0, 0, 0]
nums2 = [2, 5, 6]
m = 3
n = 3
merge(nums1, m, nums2, n)
print(f"Approach 2: Merge from the End (Optimal & In-Place) {nums1}\nTime Complexity: O(m + n)\nSpace Complexity: O(1)")



# Approach 1: Merge from the Front (Naive but Intuitive)

def merge1(nums1, m, nums2, n):
    """
    Naive merge approach — merge from the front using a temporary array.
    This method is easy to understand but uses extra space O(m).
  """
    
    # step 1: make a copy of the first m elements of nums1
    temp = nums1[:m]

    #  pointers
    i = 0 # Pointer for temp (nums1’s original elements) 
    j = 0 # Pointer for nums2 
    k = 0 # Pointer for nums1 (final position to fill)

    while i  < m and j < n:
        if temp[i] <= nums2[j]:
            nums1[k] = temp[i]
            i += 1
        else:
            nums1[k] = nums2[j]
            j += 1
        k += 1
    # Step 3: If there are remaining elements in temp, add them
    while i < m:
        nums1[k] = temp[i]
        i += 1
        k += 1

    # Step 4: If there are remaining elements in nums2, add them
    while j < n:
        nums1[k] = nums2[j]
        j += 1
        k += 1


nums1 = [1, 2, 3, 0, 0, 0]
nums2 = [2, 5, 6]
merge1(nums1, 3, nums2, 3)
print(f"Approach 1: Merge from the Front (Naive but Intuitive {nums1} \n Time Complexity: O(m + n) \n Space Complexity: O(m)")


