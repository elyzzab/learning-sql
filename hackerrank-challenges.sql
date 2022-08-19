# This file holds notable challenges from Hackerrank that really stretched my knowledge of SQL.


# The PADS [Medium]: https://www.hackerrank.com/challenges/the-pads/problem
SELECT CONCAT(Name, "(", LEFT(Occupation, 1), ")")
FROM OCCUPATIONS
ORDER BY Name ASC;

SELECT CONCAT("There are a total of ", COUNT(Occupation), " ", LOWER(Occupation), "s.")
FROM OCCUPATIONS
GROUP BY Occupation
ORDER BY COUNT(Occupation) ASC, Occupation ASC;


# Occupations [Medium]: https://www.hackerrank.com/challenges/occupations/problem
SET @d=0,@a=0,@p=0,@s=0;
SELECT MIN(Doctor),MIN(Professor),MIN(SINGER),MIN(Actor)
FROM
(   SELECT
        IF(OCCUPATION='Actor',NAME,NULL) AS Actor,
        IF(OCCUPATION='Doctor',NAME,NULL) AS Doctor,
        IF(OCCUPATION='Professor',NAME,NULL) AS Professor,
        IF(OCCUPATION='Singer',NAME,NULL) AS SINGER,
        case OCCUPATION
            when 'Actor' THEN @a:=@a+1
            when 'Doctor' THEN @d:=@d+1
            when 'Professor' THEN @p:=@p+1
            when 'Singer' THEN @s:=@s+1
            end as idn
    FROM OCCUPATIONS
    ORDER BY NAME ) AS TMP
GROUP BY TMP.idn ;


# Weather Observation Station 18 [Medium]: https://www.hackerrank.com/challenges/weather-observation-station-18/problem
SELECT ROUND( (MAX(LAT_N)-MIN(LAT_N)) + (MAX(LONG_W)-MIN(LONG_W) ),4)
FROM STATION;


# Weather Observation Station 19 [Medium]: https://www.hackerrank.com/challenges/weather-observation-station-19/problem
SELECT ROUND(
    SQRT(
        POWER(MAX(LAT_N)-MIN(LAT_N),2) + POWER(MAX(LONG_W)-MIN(LONG_W),2) ), 4
        )
FROM STATION;


# Weather Observation Station 20 [Medium]: https://www.hackerrank.com/challenges/weather-observation-station-20/problem
SET @rowindex:=-1;
SELECT
   ROUND(AVG(l.LAT_N),4) as Median
FROM
   (SELECT @rowindex:=@rowindex+1 AS rowindex,
           STATION.LAT_N
    FROM STATION
    ORDER BY LAT_N) as l
WHERE
l.rowindex IN (FLOOR(@rowindex / 2), CEIL(@rowindex / 2));
