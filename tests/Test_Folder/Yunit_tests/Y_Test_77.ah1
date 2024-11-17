var = 3.1415
if var is not float
   FileAppend, %var% is not float, *
else if var is not integer
   FileAppend, %var% is not int, *