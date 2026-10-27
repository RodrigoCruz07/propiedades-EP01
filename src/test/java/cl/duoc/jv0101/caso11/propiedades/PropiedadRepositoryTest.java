package cl.duoc.jv0101.caso11.propiedades;

import java.math.BigDecimal;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.orm.jpa.DataJpaTest;
import cl.duoc.jv0101.caso11.propiedades.model.Propiedad;
import cl.duoc.jv0101.caso11.propiedades.repository.PropiedadRepository;

import static org.assertj.core.api.Assertions.assertThat;

/** Prueba de integracion de la capa de persistencia (H2 en memoria). */
@DataJpaTest
class PropiedadRepositoryTest {

    @Autowired
    private PropiedadRepository repository;

    @Test
    void guardaYRecuperaPropiedad() {
        Propiedad p = new Propiedad();
        p.setNombre("Depto Viña");
        p.setTipo("departamento");
        p.setPrecio(new BigDecimal("450000"));

        Propiedad guardada = repository.save(p);

        assertThat(guardada.getId()).isNotNull();
        assertThat(repository.findById(guardada.getId()))
            .get()
            .extracting(Propiedad::getNombre)
            .isEqualTo("Depto Viña");
    }
}
