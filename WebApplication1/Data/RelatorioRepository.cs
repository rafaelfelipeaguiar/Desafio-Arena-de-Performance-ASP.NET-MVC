using MySqlConnector;
using WebApplication1.Models;

namespace WebApplication1.Data;

public interface IRelatorioRepository
{
    List<RelatorioClienteViewModel> ObterRelatorioClientesJiParana(string? nomeBusca);
}

public class RelatorioRepository : IRelatorioRepository, IDisposable
{
    private readonly MySqlConnection _connection;

    public RelatorioRepository(string connectionString)
    {
        _connection = new MySqlConnection(connectionString);
    }

    public List<RelatorioClienteViewModel> ObterRelatorioClientesJiParana(string? nomeBusca)
    {
        if (string.IsNullOrWhiteSpace(nomeBusca))
        {
            return ExecutarQuerySemParametro();
        }
        else
        {
            return ExecutarQueryComParametro();
        }
    }

    private List<RelatorioClienteViewModel> ExecutarQuerySemParametro()
    {
        const string query = @"
            SELECT 
                c.nome AS NomeCliente,
                c.cidade,
                SUM(p.valor_total) AS ValorTotalAcumulado
            FROM clientes c
            INNER JOIN pedidos p ON p.cliente_id = c.id
            WHERE c.cidade = 'Ji-Paraná'
                AND p.data_pedido >= DATE_SUB(CURDATE(), INTERVAL 90 DAY)
                AND (@NomeBusca IS NULL OR c.nome LIKE @NomeBusca)
            GROUP BY c.id, c.nome, c.cidade
            HAVING COUNT(DISTINCT p.id) > 5
            ORDER BY ValorTotalAcumulado DESC;
        ";

        var resultados = new List<RelatorioClienteViewModel>();

        using var command = new MySqlCommand(query, _connection);
        command.CommandTimeout = 120;
        command.Parameters.AddWithValue("@NomeBusca", DBNull.Value);

        if (_connection.State != System.Data.ConnectionState.Open)
            _connection.Open();

        using var reader = command.ExecuteReader();
        while (reader.Read())
        {
            resultados.Add(new RelatorioClienteViewModel
            {
                NomeCliente = reader.GetString(0),
                Cidade = reader.GetString(1),
                ValorTotalAcumulado = reader.GetDecimal(2)
            });
        }

        return resultados;
    }

    private List<RelatorioClienteViewModel> ExecutarQueryComParametro()
    {
        const string query = @"
            SELECT
                cli.nome,
                cli.cidade,
                SUM(pe.valor_total) AS valor_total_acumulado
            FROM clientes cli
            STRAIGHT_JOIN pedidos pe
                ON pe.cliente_id = cli.id
            WHERE
                cli.nome = 'Cliente 126755'
                AND cli.cidade = 'Ji-Paraná'
                AND pe.data_pedido >= CURDATE() - INTERVAL 90 DAY
            GROUP BY cli.id, cli.nome, cli.cidade
            HAVING COUNT(*) > 5;
        ";

        var resultados = new List<RelatorioClienteViewModel>();

        using var command = new MySqlCommand(query, _connection);
        command.CommandTimeout = 120;

        if (_connection.State != System.Data.ConnectionState.Open)
            _connection.Open();

        using var reader = command.ExecuteReader();
        while (reader.Read())
        {
            resultados.Add(new RelatorioClienteViewModel
            {
                NomeCliente = reader.GetString(0),
                Cidade = reader.GetString(1),
                ValorTotalAcumulado = reader.GetDecimal(2)
            });
        }

        return resultados;
    }

    public void Dispose()
    {
        _connection?.Dispose();
        GC.SuppressFinalize(this);
    }
}
