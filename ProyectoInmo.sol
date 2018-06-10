pragma solidity ^0.4.0;

contract ContratoConstructora{ 
	// Struct Persona es el diccionario que guarda los datos de cada cliente
	struct Persona{
		string NombreCo;
		string ApellidosCo;
		uint Cedula;
		uint Pagos;
		uint256 ValorCuota;
		uint NumerodeCuotas;
		uint256 TotalValor;
		uint NumerodeApartamento;
		bool activate;
		uint256 TiempoUltimoPago; 
		uint CuotasRestrasadas;
	}
	//Configuración del proyecto inmobiliario. Algunos parámetros se agregan desde el código.
	string public NombredelProyectoInmobiliario;  //Nombre del proyecto inmobiliario
	uint256 CuotaInicialSep=300000000000000;  //El valor de la cuota inicial del apartamento
	uint CantidadApartamentos= 100;   // Cantidad de apartamentos disponibles del proyecto
	uint Descuento=40;   // La porcentaje de la penalizacion que se hará al cliente que incumpla (se le retorna el dinero)
	uint k=100;     
	uint lk;
	uint256 CantidadGanrantia=30000000000;  // La cantidad de dinero que debe reterner el contrato hasta la finalización del contrato
	
	
	address owner; //Constructora 
	uint256 public FechalimiteSobrePlanos;  // Fecha en la que termina la venta sobre planos
	uint256 public FechalimiteConstruccion; // Fecha en la que termina la construccion
	

   //Creación del contrato por la Constructora. Esta función se ejecuta en fase 'deploy' del contrato.
	function ContratoConstructora(string _ProyInmobiliario, uint256 _FechaPlanos, uint256 _FechaConstruccion){
			owner=msg.sender;
			NombredelProyectoInmobiliario=_ProyInmobiliario;
			FechalimiteSobrePlanos=_FechaPlanos;
			FechalimiteConstruccion=_FechaConstruccion;
			// UserStatus('El proyecto de construccion: ', _ProyInmobiliario, ' ha sido creado. Tiempo:', block.timestamp); 
	} 
 	
 	// Diccionario de arreglo de personas que se han registrado (se hace public para que lo usuarios puedan consultar el
 	// el estado de su cuenta en el proyecto)	
	mapping(address=>Persona) public Lista;
	// Lista de direcciones que se han registrado como cliente. Se registran las direcciones desde la cuales se han registrado
	address[] addressIndices;
	
	//Funcion que se ejecuta para crear una cliente. Debe hacer el pago inicial (una transferencia) con un valor acordado
	// para que permita el registro.
	function RegistroNuevoCliente(string _NombreCo, string _ApellidosCo, uint _Cedula,  uint256 _ValorCuota, uint _NumerodeCuotas, uint _NuApartamento) payable {
		if(msg.value==CuotaInicialSep){
		// Si el pago es el adecuado se hace el registro del cliente.
			Lista[msg.sender]=Persona({
			NombreCo: _NombreCo, 
			ApellidosCo: _ApellidosCo,
			Cedula:_Cedula,
			activate: true,
			Pagos: 1,
			ValorCuota:_ValorCuota,
			NumerodeCuotas:_NumerodeCuotas, 
			TotalValor:CuotaInicialSep,
			NumerodeApartamento:_NuApartamento, 
			TiempoUltimoPago: block.timestamp,
			CuotasRestrasadas:0
			});	
			CantidadApartamentos=CantidadApartamentos-1;
			addressIndices.push(msg.sender);
			// UserStatus('El cliente: ', _NombreCo, ' ha seleccionado el Apartamento: ', _NuApartamento, 'Tiempo de la transación:', block.timestamp); 
		} else {
		// Esto no permite que se agregue el cliente si el valor del pago inicial no es el acordado
			revert();
		}
	}	
	
	// Para que el cliente haga los pagos mensualmente
	function PagoCuotaMensual() payable{
		if (msg.value==Lista[msg.sender].ValorCuota){
			Lista[msg.sender].Pagos=Lista[msg.sender].Pagos+1;
			Lista[msg.sender].TotalValor=Lista[msg.sender].TotalValor+Lista[msg.sender].ValorCuota;
			Lista[msg.sender].TiempoUltimoPago=block.timestamp;
			Lista[msg.sender].NumerodeCuotas=Lista[msg.sender].NumerodeCuotas-1;
			Lista[msg.sender].CuotasRestrasadas=0;
		}else {
			revert();
		}
	}
    // Para cancelar la Separacion del apartamento.
	function CancelarSeparacionApartamento(){
		if (Lista[msg.sender].activate){ 
		Lista[msg.sender].activate=false;
		msg.sender.transfer((Lista[msg.sender].TotalValor*Descuento)/100);
		CantidadApartamentos=CantidadApartamentos+1;
		}else{
			revert();
		}
	}
	//Transferencia del dinero Captado por el contrato a la constructora al terminar la fase de ventas sobre planos
	function TransferenciaDeDineroConstrutora() {
		if(block.timestamp>=FechalimiteSobrePlanos){		
			owner.transfer((this.balance)*0.6);
		}else{
			revert();
		}
	}
	//Temporizador para validar los pagos mensualmente  de los usuarios. En caso de incumplimiento de 3 o mas meses, se le 
	//penaliza devolviendole una parte del dinero y liberando el apartamento
	function CortesDelMes(){
		uint arrayLength = addressIndices.length;
       	for (uint i=0; i<arrayLength; i++) {
  			lk=now-Lista[addressIndices[i]].TiempoUltimoPago;
  			if (lk>k){
  					Lista[addressIndices[i]].activate=false;
  					addressIndices[i].transfer((Lista[addressIndices[i]].TotalValor*Descuento)/100);
					CantidadApartamentos= CantidadApartamentos+1;
  			}else{
  				revert();
  			}
  		}
	}  
}



