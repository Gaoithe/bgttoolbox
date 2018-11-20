

for a in range(2,6):
 for b in range(2,6):
  if a != b:
   for c in range(2,6):
    if a != c and b != c:
     for d in range(2,6):
      if a != d and b != d and c != d:
       for x1 in ['+','-','*','/']:
        for x2 in ['+','-','*','/']:
         for x3 in ['+','-','*','/']:
          sum = "((float(%d)%sfloat(%d))%sfloat(%d))%sfloat(%d)"%(a,x1,b,x2,c,x3,d)
          ans = eval(sum)
          print "sum:%s ans:%f" % (sum,ans)
