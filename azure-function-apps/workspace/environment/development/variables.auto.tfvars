resource = {
    naming = {
        environment = "d", region = "va2"
    }

    tags = {
        Live = "no"
        TechnicalService = "Development"
        SupportDL = "himani.yadav@xyz.com"
        AccessType = "Internal"
    }
}

environment = {
    metadata = {
        source = "workspace/environment/development"
        contact = "himani.yadav@xyz.com"

        sequence = "000"
        primary_key = "np-dev"
    }
}

WhiteListedCIDRRange = [ "52.185.75.16/28" ]

image = "flask"