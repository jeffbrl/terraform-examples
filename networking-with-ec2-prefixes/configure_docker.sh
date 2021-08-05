#!/bin/bash -xe

public_subnet_ipv4="100.64.0.0/20"

if ! command -v jq &> /dev/null
then
    echo "This script requires the jq program. Install it and re-run the script."
    exit
fi
#bastion_ip=`terraform show --json | jq -r .values.outputs.bastion_ip.value`
docker_host_dns=`terraform show --json | jq -r .values.outputs.docker_host_dns.value`
docker_eni=`terraform show --json | jq -r .values.outputs.docker_eni.value`
#echo "bastion_ip: $bastion_ip"
echo "docker_host_dns: $docker_host_dns"
echo "docker_eni: $docker_eni"
ipv4_prefix=`aws ec2 describe-network-interfaces --network-interface-id $docker_eni --region us-east-1 --output json --query "NetworkInterfaces[0].Ipv4Prefixes[0].Ipv4Prefix" | tr -d \"`
ipv6_prefix=`aws ec2 describe-network-interfaces --network-interface-id $docker_eni --region us-east-1 --output json --query "NetworkInterfaces[0].Ipv6Prefixes[0].Ipv6Prefix"  | tr -d \"`
public_subnet=`aws ec2 describe-network-interfaces --network-interface-id $docker_eni --region us-east-1 --output json --query "NetworkInterfaces[0].SubnetId"  | tr -d \"`
public_subnet_ipv6=`aws ec2 describe-subnets --subnet-id $public_subnet --region us-east-1 --query Subnets[0].Ipv6CidrBlockAssociationSet[0].Ipv6CidrBlock | tr -d \"`

ssh_options="-o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no"


cat << EOF > /tmp/script.$$ 
#!/bin/bash
sudo docker network create --ipv6 -d ipvlan -o parent=eth0 --subnet $public_subnet_ipv4 \
--ip-range=$ipv4_prefix --subnet $public_subnet_ipv6 --ip-range $ipv6_prefix dockernet
sudo docker network ls 
sudo docker run --rm -d --net dockernet gcr.io/stately-minutia-658/jweb
sudo docker run --rm -d --net dockernet gcr.io/stately-minutia-658/jweb
sudo docker run --rm -d --net dockernet gcr.io/stately-minutia-658/jweb
EOF

scp -i mykey $ssh_options /tmp/script.$$ ec2-user@$docker_host_dns:/tmp/script.$$
#ssh -i mykey $ssh_options ec2-user@$docker_host_dns "bash /tmp/script.$$"
