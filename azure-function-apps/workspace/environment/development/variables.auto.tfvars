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
        source = "azure-functions-apps/workspace/environment/development"
        contact = "himani.yadav@xyz.com"

        sequence = "000"
        primary_key = "np-dev"
    }
}

WhiteListedCIDRRange = [ "23.34.45.56/67" ] #Please add cidr ranges

image = "flask"