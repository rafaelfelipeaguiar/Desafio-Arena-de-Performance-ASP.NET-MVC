using Microsoft.AspNetCore.Mvc;
using WebApplication1.Data;
using WebApplication1.Models;

namespace WebApplication1.Controllers;

public class RelatorioController : Controller
{
    private readonly IRelatorioRepository _repository;

    public RelatorioController(IRelatorioRepository repository)
    {
        _repository = repository;
    }

    public IActionResult Index(string? nomeBusca)
    {
        var model = new RelatorioFiltroViewModel
        {
            NomeBusca = nomeBusca,
            Resultados = _repository.ObterRelatorioClientesJiParana(nomeBusca)
        };

        return View(model);
    }
}
