terraform{
    required_providers{
        aws = {
            source  = "hashicorp/aws"
            version = "5.62.0"
        }
        terracurl = {
              source  = "devops-rob/terracurl"
              version = "1.2.1"
        }
    }
}
provider "aws" {
}
provider "terracurl" {
}
