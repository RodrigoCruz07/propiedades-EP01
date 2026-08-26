package cl.duoc.jv0101.caso11.propiedades.repository;

import org.springframework.data.jpa.repository.JpaRepository;
import cl.duoc.jv0101.caso11.propiedades.model.Propiedad;

public interface PropiedadRepository extends JpaRepository<Propiedad, Long> {
}
