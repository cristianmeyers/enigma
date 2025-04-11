function test() {
  bash test.sh <<EOF > /dev/null 2>&1
5
10
20
EOF
}
test
