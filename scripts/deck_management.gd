extends Node
class_name DeckManager


var decks: Dictionary = {
	"paladin": [
		"corte", "corte_plus", "corte_duplo", "corte_duplo_plus", "corte_tornado",
		"corte_tornado_plus", "corte_rapido", "corte_rapido_plus", "bloquear",
		"bloquear_plus", "envenenar", "envenenar_plus", "pocao_vida", "fortalecer",
		"nevoa_venenosa", "enfraquecer", "toque_estatico", "refletir"
	]
}

var passives_description: Dictionary = {
	"burning fury": "Dano aumentado em +2",
	"rock hull": "Reduz o dano recebido em 1",
	"protective shadows": "30% de chance de esquivar o ataque recebido",
	"tenacity": "Se for receber dano fatal, não morre e fica com 1 de vida",
	"final fury": "Se a vida estiver abaixo de 50%, o dano aumenta em +4",
	"vital roots": "Recupera 3 de vida a cada turno",
	"retaliatory toxin": "Se receber dano direto, causa 1 de veneno",
	"battle thirst": "A cada 2 ataques, recupera 5 de vida",
	"last breath": "Ao morrer, causa 10 de dano em todos",
	"rebirthing": "Ao morrer a primeira vez, revive com 50% de vida",
	"enrage": "Se for o último vivo, aumenta o dano em +10"
}
