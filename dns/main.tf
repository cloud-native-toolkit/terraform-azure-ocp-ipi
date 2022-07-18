
resource "azurerm_dns_cname_record" "api_external" {
    name                = "api.${var.cluster_name}"
    zone_name           = var.base_domain
    resource_group_name = var.domain_resource_group_name
    ttl                 = var.ttl
    record              = var.external_lb_fqdn
}

resource "azurerm_private_dns_zone" "private" {
    depends_on = [
      azurerm_dns_cname_record.api_external
    ]

    name                = "${var.cluster_name}.${var.base_domain}"
    resource_group_name = var.resource_group_name
}

resource "azurerm_private_dns_zone_virtual_network_link" "network" {
    name                  = "${var.cluster_infra_name}-network-link"
    resource_group_name   = var.resource_group_name
    private_dns_zone_name = azurerm_private_dns_zone.private.name
    virtual_network_id    = var.virtual_network_id
}

resource "azurerm_private_dns_a_record" "api_internal" {
    name                = "api"
    zone_name           = azurerm_private_dns_zone.private.name
    resource_group_name = var.resource_group_name
    ttl                 = var.ttl
    records             = [var.internal_lb_ip]
}

resource "azurerm_private_dns_a_record" "apiint_internal" {
    name                = "api-int"
    zone_name           = azurerm_private_dns_zone.private.name
    resource_group_name = var.resource_group_name
    ttl                 = var.ttl
    records             = [var.internal_lb_ip]
}



