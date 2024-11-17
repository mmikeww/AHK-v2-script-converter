var = 3.1415
if var is float
   FileAppend, %var% is float, *
else if var is integer
   FileAppend, %var% is int, *