for problem in vampire/p*.pddl; do
    ./downward-main/fast-downward.py vampire/domain.pddl "$problem" --search "astar(const())" | grep "Plan cost:" | awk -F' ' '{print $NF}'
done