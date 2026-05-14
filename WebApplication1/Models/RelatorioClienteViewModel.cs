namespace WebApplication1.Models;

public class RelatorioClienteViewModel
{
    public string NomeCliente { get; set; } = string.Empty;
    public string Cidade { get; set; } = string.Empty;
    public decimal ValorTotalAcumulado { get; set; }
}

public class RelatorioFiltroViewModel
{
    public string? NomeBusca { get; set; }
    public List<RelatorioClienteViewModel> Resultados { get; set; } = new();
}
