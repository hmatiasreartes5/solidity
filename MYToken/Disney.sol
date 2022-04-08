// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;
pragma experimental ABIEncoderV2;
import "./MyToken.sol";

contract Disney {
    MyToken private token;
    address payable public owner;

    constructor() {
        token = new MyToken(1000);
        owner = payable(msg.sender);
    }

    struct Cliente {
        uint tokensComprados;
        string [] atraccionesUsadas;
    }

    mapping (address => Cliente) public clientes;

    // ------------------------------------ GESTION DE TOKENS ---------------------------------
    modifier onlyOwner(address _direccion) {
        require(_direccion == owner, "No tenes permisos para ejecutar esta funcion");
        _;
    }

    function precioToken(uint _numTokens) internal pure returns (uint) {
        return _numTokens*(1 ether);
    }

    function balanceOf() public view returns (uint) {
        return token.balanceOf(address(this));
    }

    function misTokens() public view returns (uint) {
        return token.balanceOf(msg.sender);
    }

    function generarTokens(uint _numTokens) public onlyOwner(msg.sender) {
        token.increaseTotalSupply(_numTokens);
    }

    function comprarTokens(uint _numTokens) public payable {
        uint coste = precioToken(_numTokens);
        require(msg.value >= coste, "Invalid ether amount");

        uint returnValue = msg.value - coste;

        /*
        Example: el cliente intenta comprar 5 tokens con 10 ethers
        entonces se procede a devolver la diferencia
        */
        payable(msg.sender).transfer(returnValue);

        uint balance = balanceOf();
        require(_numTokens <= balance, "Compra un numero menor de tokens");
        token.transfer(msg.sender, _numTokens);
        clientes[msg.sender].tokensComprados += _numTokens;
    }

    // ------------------------------------ GESTION DE DISNEY ---------------------------------

    //Events
    event atraccionSubida(string, uint, address);
    event nuevaAtraccion(string, uint);
    event bajaAtraccion(string);
    event comidaAdquirida(string, uint, address);
    event nuevaComida(string, uint);
    event bajaComida(string);

    struct Atraccion {
        string nombre;
        uint precio;
        bool estado;
    }

    struct Comida {
        string nombre;
        uint precio;
        bool estado;
    }

    mapping (string => Atraccion) atracciones;
    mapping (string => Comida) comidas;

    //Mappings para relacionar el historial de atracciones y comidas (del cliente) dentro de Disney
    mapping (address => string []) historialAtracciones;
    mapping (address => string []) historialComidas; 

    string [] atraccionesDisney;
    string [] comidasDisney;

    /*
     SECCION ATRACCIONES
    */
    function postAtraccion(string memory _nombre, uint _precio) public onlyOwner(msg.sender) {
        atracciones[_nombre] = Atraccion(_nombre, _precio, true);
        atraccionesDisney.push(_nombre);
        emit nuevaAtraccion(_nombre, _precio);
    }

    function darBajaAtraccion(string memory _nombre) public onlyOwner(msg.sender) {
        require(keccak256(abi.encodePacked(atracciones[_nombre].nombre)) == keccak256(abi.encodePacked(_nombre)), "No existe esta atraccion");
        atracciones[_nombre].estado = false;
        emit bajaAtraccion(_nombre);
    }

    function darAltaAtraccion(string memory _nombre) public onlyOwner(msg.sender) {
        atracciones[_nombre].estado = true;
    }

    function getAtraccionesDisney() public view returns (string [] memory) {
        return atraccionesDisney;
    }

    function getEstadoAtraccion(string memory _nombre) public view returns (bool) {
        return atracciones[_nombre].estado;
    }

    function subirseAtraccion(string memory _nombre) public {
        uint precioAtraccion = atracciones[_nombre].precio;

        require(atracciones[_nombre].estado == true, "Atraccion no disponible");
        require(precioAtraccion <= misTokens(), "No tienes los tokens necesarios para subirte a esta atraccion");

        /*
        Fue necesario crear una funcion en MyToken.sol
        dado a que en caso de usar el Transfer o TransferFrom las direcciones que se escogian 
        para realizar la transccion eran equivocadas. Ya que el msg.sender que recibia el metodo Transfer o
        TransferFrom era la direccion del contrato
        */
        token.transferDisney(msg.sender, address(this), precioAtraccion);

        historialAtracciones[msg.sender].push(_nombre);
        emit atraccionSubida(_nombre, precioAtraccion, msg.sender);
    }

    function getHistorialAtraccionesCliente() public view returns (string[] memory ) {
        return historialAtracciones[msg.sender];
    }

    /*
    SECCION COMIDAS
    */
    function postComida(string memory _nombre, uint _precio) public onlyOwner(msg.sender) {
        comidas[_nombre] = Comida(_nombre, _precio, true);
        comidasDisney.push(_nombre);
        emit nuevaComida(_nombre, _precio);
    }

    function darBajaComida(string memory _nombre) public onlyOwner(msg.sender) {
        require(keccak256(abi.encodePacked(comidas[_nombre].nombre)) == keccak256(abi.encodePacked(_nombre)), "No existe esta comida");
        comidas[_nombre].estado = false;
        emit bajaComida(_nombre);
    }

    function darAltaComida(string memory _nombre) public onlyOwner(msg.sender) {
        comidas[_nombre].estado = true;
    }

    function getComidasDisney() public view returns (string [] memory) {
        return comidasDisney;
    }

    function getEstadoComida(string memory _nombre) public view returns (bool) {
        return comidas[_nombre].estado;
    }

    function comprarComida(string memory _nombre) public {
        uint precioComida = comidas[_nombre].precio;

        require(comidas[_nombre].estado == true, "Comida no disponible");
        require(precioComida <= misTokens(), "No tienes los tokens necesarios para subirte a esta atraccion");

        /*
        Fue necesario crear una funcion en MyToken.sol
        dado a que en caso de usar el Transfer o TransferFrom las direcciones que se escogian 
        para realizar la transccion eran equivocadas. Ya que el msg.sender que recibia el metodo Transfer o
        TransferFrom era la direccion del contrato
        */
        token.transferDisney(msg.sender, address(this), precioComida);

        historialComidas[msg.sender].push(_nombre);
        emit comidaAdquirida(_nombre, precioComida, msg.sender);
    }

    function getHistorialComidasCliente() public view returns (string[] memory ) {
        return historialAtracciones[msg.sender];
    }

    /*
    SALIDA DE DISNEY 
    */
    function devolverTokens(uint _numTokens) public payable {
        require(_numTokens > 0, "Necesitas devolver una cantidad positiva de tokens");
        require(_numTokens <= misTokens(), "No tienes los tokens suficientes que deseas devolver");

        //El cliente devuelve los tokens
        token.transferDisney(msg.sender, address(this), _numTokens);

        //Devolucion en ether del valor de los tokens
        payable(msg.sender).transfer(precioToken(_numTokens));
    }
}