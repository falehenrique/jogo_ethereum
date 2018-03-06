pragma solidity ^0.4.18;

contract MeuJogo {

    address public donoJogo;

    enum EstadoJogo{ABERTO, AGUARDANDO_SAQUE, FECHADO}
    EstadoJogo public estadoJogo;

    uint256 public valorJogo;
    uint256 public quantidadeJogadores;
    
    uint8[] public numerosJogo;
    uint256 private numeroPremiado;
    uint256 public saldojogo;

    event LogAposta(address endereco);
    event LogNotificarGanhador(address endereco);


    mapping (address=>Jogador) mapAddressJogador;
    Jogador[] public jogadores;

    function MeuJogo() public {
        donoJogo = msg.sender;
        valorJogo = 1 ether;
        quantidadeJogadores = 3;
        numerosJogo = [1,2,3];
        estadoJogo = EstadoJogo.ABERTO;
        gerarNumeroPremiado();
    }

    struct Jogador {
        address enderecoJogador;
        bool inscrito;
        uint8 jogo;
        bool vencedor;
    }

    function gerarNumeroPremiado() private {
        numeroPremiado = 2;
    }

    function() public payable { }

    function jogar(uint8 _jogo) payable public {
        require(msg.value == valorJogo);
        require(estadoJogo == EstadoJogo.ABERTO);

        assert(!mapAddressJogador[msg.sender].inscrito);

        Jogador memory jogador = Jogador ({
            enderecoJogador: msg.sender,
            inscrito: true,
            jogo: _jogo,
            vencedor: false
        });
        mapAddressJogador[msg.sender] = jogador;
        jogadores.push(jogador);
        
        saldojogo += msg.value;

        this.transfer(msg.value);

        LogAposta(msg.sender);


        verificarQuantidadeApostas();
    }

    function verificarQuantidadeApostas() private {
        if (quantidadeJogadores == jogadores.length) {
            LogNotificarGanhador(verificarGanhador());
        }
    }

    function verificarGanhador() private returns(address) {
        for (uint i = 0; i < jogadores.length; i++) {
            if (jogadores[i].jogo == numeroPremiado) {
                jogadores[i].vencedor = true;
                mapAddressJogador[jogadores[i].enderecoJogador].vencedor = true;
                estadoJogo = EstadoJogo.AGUARDANDO_SAQUE;
                return jogadores[i].enderecoJogador;
            }
        }
    }


    function sacarPremio() public {
        require(mapAddressJogador[msg.sender].inscrito);
        require(estadoJogo == EstadoJogo.AGUARDANDO_SAQUE);
        require(mapAddressJogador[msg.sender].vencedor);

        estadoJogo = EstadoJogo.FECHADO;        
        msg.sender.transfer(this.balance);
    }

    function consultarNumeroPremiado() public view returns (uint256) {
        require(estadoJogo == EstadoJogo.FECHADO);
        return numeroPremiado;
    }

    function quantidadeJogadores() public view returns(uint256) {
        return jogadores.length;
    }

    function estadoJogo() public view returns(string) {
        if (estadoJogo == EstadoJogo.ABERTO) {
            return "ABERTO";
        } else if (estadoJogo == EstadoJogo.AGUARDANDO_SAQUE) {
            return "AGUARDANDO_SAQUE";
        } else {
            return "FECHADO";
        }
    }


}