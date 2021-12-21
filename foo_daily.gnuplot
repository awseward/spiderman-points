set datafile separator ','

set title 'Points'

set xdata time
set timefmt "%Y-%m-%d"
set format x "%Y-%m-%d"

set ytics 10 nomirror tc lt 1
set ylabel 'points awarded'

set y2tics 10 nomirror tc lt 3
set y2label 'percentile'

set boxwidth 0.8 relative
set style fill solid

plot \
  'foo_daily.csv' using 1:2 title 'points awarded' with boxes, \
  'foo_daily.csv' using 1:2:2 with labels offset char 0,-1 notitle, \
  'foo_daily.csv' using 1:3 title 'percentile' axes x1y2 with linespoints, \
  'foo_daily.csv' using 1:3:3 axes x1y2 with labels notitle
