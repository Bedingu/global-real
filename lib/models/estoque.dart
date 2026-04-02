enum EstoqueStatus {
  disponivel,
  reservado,
  vendido,
  expirado,
}

enum CampanhaTipo {
  nenhuma,
  globalWeek,
  flashSale,
}

class EstoqueModel {
  final String id;

  /// Empreendimento
  final String empreendimento;
  final String unidade;
  final double metragem;

  /// Valores
  final double valorTabela;
  final double valorTabelao;
  final double valorCampanha;

  /// Datas
  final DateTime campanhaInicio;
  final DateTime campanhaFim;

  /// Reserva
  final DateTime? reservadoAte;

  /// Controle
  final EstoqueStatus status;
  final CampanhaTipo campanhaTipo;

  const EstoqueModel({
    required this.id,
    required this.empreendimento,
    required this.unidade,
    required this.metragem,
    required this.valorTabela,
    required this.valorTabelao,
    required this.valorCampanha,
    required this.campanhaInicio,
    required this.campanhaFim,
    this.reservadoAte,
    required this.status,
    required this.campanhaTipo,
  });

  /// Verifica se campanha está ativa
  bool get campanhaAtiva {
    final now = DateTime.now();
    return now.isAfter(campanhaInicio) && now.isBefore(campanhaFim);
  }

  /// Verifica se pode reservar
  bool get podeReservar {
    return status == EstoqueStatus.disponivel && campanhaAtiva;
  }

  /// Desconto percentual
  double get descontoPercentual {
    return ((valorTabela - valorCampanha) / valorTabela) * 100;
  }

  /// JSON → Model
  factory EstoqueModel.fromJson(Map<String, dynamic> json) {
    return EstoqueModel(
      id: json['id'],
      empreendimento: json['empreendimento'],
      unidade: json['unidade'],
      metragem: (json['metragem'] as num).toDouble(),
      valorTabela: (json['valor_tabela'] as num).toDouble(),
      valorTabelao: (json['valor_tabelao'] as num).toDouble(),
      valorCampanha: (json['valor_campanha'] as num).toDouble(),
      campanhaInicio: DateTime.parse(json['campanha_inicio']),
      campanhaFim: DateTime.parse(json['campanha_fim']),
      reservadoAte: json['reservado_ate'] != null
          ? DateTime.parse(json['reservado_ate'])
          : null,
      status: EstoqueStatus.values.firstWhere(
            (e) => e.name == json['status'],
        orElse: () => EstoqueStatus.disponivel,
      ),
      campanhaTipo: CampanhaTipo.values.firstWhere(
            (e) => e.name == json['campanha_tipo'],
        orElse: () => CampanhaTipo.nenhuma,
      ),
    );
  }

  /// Model → JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'empreendimento': empreendimento,
      'unidade': unidade,
      'metragem': metragem,
      'valor_tabela': valorTabela,
      'valor_tabelao': valorTabelao,
      'valor_campanha': valorCampanha,
      'campanha_inicio': campanhaInicio.toIso8601String(),
      'campanha_fim': campanhaFim.toIso8601String(),
      'reservado_ate': reservadoAte?.toIso8601String(),
      'status': status.name,
      'campanha_tipo': campanhaTipo.name,
    };
  }

  /// Atualização parcial
  EstoqueModel copyWith({
    EstoqueStatus? status,
    DateTime? reservadoAte,
  }) {
    return EstoqueModel(
      id: id,
      empreendimento: empreendimento,
      unidade: unidade,
      metragem: metragem,
      valorTabela: valorTabela,
      valorTabelao: valorTabelao,
      valorCampanha: valorCampanha,
      campanhaInicio: campanhaInicio,
      campanhaFim: campanhaFim,
      reservadoAte: reservadoAte ?? this.reservadoAte,
      status: status ?? this.status,
      campanhaTipo: campanhaTipo,
    );
  }
}