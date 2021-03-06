#!/bin/bash

rm -f last_checkpoint.out
pkill -f cartpole_server.py
sleep 1

if [ -f test_local_inference.sh ]; then
    basedir="../../examples/serving"
else
    basedir="rllib/examples/serving"  # In bazel.
fi

(python $basedir/cartpole_server.py --run=PPO 2>&1 | grep -v 200) &
pid=$!

echo "Waiting for server to start"
while ! curl localhost:9900; do
  sleep 1
done

sleep 2
python $basedir/cartpole_client.py --stop-reward=150 --inference-mode=local
kill $pid
