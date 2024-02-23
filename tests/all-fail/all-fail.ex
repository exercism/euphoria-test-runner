public function leap(integer year) 
    return not (remainder(year, 4) = 0 and (remainder(year, 100) != 0 or remainder(year, 400) = 0))
end function