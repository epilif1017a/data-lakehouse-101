# data-lakehouse-101
Framework & templates for [The Complete Guide for Building a Modern Decentralized Data Platform for the Generative AI Era](https://medium.com/@epilif1017a/the-complete-guide-for-building-a-modern-federated-data-platform-for-the-generative-ai-era-4cee34c94881).

# Troubleshooting
## Podman does not work with Terraform Docker Provider
- Configure Podman to be compatible with Terraform's Docker Provider.
```bash
# Ensure that podman service continues running even after the user logs out.
loginctl enable-linger

# Enable the podman service
systemctl enable - user - now podman.socket
echo "alias docker='podman'" >> ~/.zshrc # or .bash_profile
source ~/.zshrc
# For a Linux system, this is what you usually need.
# Alternative: install podman-desktop and leave it open, 
# so that the socket remains active.
```

- Configure the Terrraform provider to use the Podman socket.
```bash
provider "docker" {
  host = "unix:///run/user/1000/podman/podman.sock"
}
```

## During Terraform apply or destroy, there are "container does not exist" errors
This is the main issue that led me to not continue the guide with Podman. My suspicion is that this is likely due to a bug in the Terraform Docker Provider when using Podman. If you are facing errors related to container destruction or recreation, you can do the following as a workaround:
> Terraform forces container replacement (destroy and create) every time you run terraform apply in a stack with containers. I did not find any other workaround other than the following. You might try to play with Podman's Docker compatibility options, but I did not want to make the guide to convoluted with this Docker vs. Podman thingy.

- Clean Terraform folder and state files; 
- Run `docker container rm … | docker network rm … | docker volume rm …`, or hit `terraform destroy` as many times as the items left to destroy without errors and then run `terraform apply` again.
