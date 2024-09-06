# Highly-Available WireGuard service on AWS ECS

![Highly-Available WireGuard service on AWS ECS](./docs/ecs-wireguard.drawio.png "Highly-Available WireGuard service on AWS ECS")

## Download peer configuration

Connect to the WireGuard container:

```sh
aws ecs execute-command --cluster "${CLUSTER_NAME}" \
    --task "${TASK_ID}" \
    --container wireguard \
    --interactive \
    --command "/bin/bash"
```

Copy the contents of the peer `.conf` file:

```txt
cat /config/peer_<name>/peer_<name>.conf
```

## References

<https://www.procustodibus.com/blog/2022/05/wireguard-on-ecs/>

<https://www.procustodibus.com/blog/2021/02/ha-wireguard-on-aws/>

<https://www.jdieter.net/posts/2020/05/31/multi-region-vpn-aws/>

<https://www.perdian.de/blog/2021/12/27/setting-up-a-wireguard-vpn-at-aws-using-terraform/>

### AWS

<https://repost.aws/questions/QUaG4liNoLQsymZdj3qUy8rg/troubleshoot-nlb-udp-flows>

<https://docs.aws.amazon.com/elasticloadbalancing/latest/network/load-balancer-security-groups.html>

<https://docs.aws.amazon.com/elasticloadbalancing/latest/network/target-group-health-checks.html>

### NLB healthcheck for UDP ECS service

<https://stackoverflow.com/questions/57698978/healthcheck-for-networkloadbalancer-with-udp-ecs-service>

<https://github.com/aws/containers-roadmap/issues/850>

<https://www.procustodibus.com/blog/2021/03/wireguard-health-check-for-python-3/>

## Acknowledgements

<https://github.com/rupertbg/aws-wireguard-linux>
