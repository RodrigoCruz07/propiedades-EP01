package cl.duoc.jv0101.caso11.propiedades.service;

import java.util.List;
import java.util.Optional;
import org.springframework.stereotype.Service;
import cl.duoc.jv0101.caso11.propiedades.model.Propiedad;
import cl.duoc.jv0101.caso11.propiedades.repository.PropiedadRepository;

@Service
public class PropiedadService {

    private final PropiedadRepository repository;

    public PropiedadService(PropiedadRepository repository) {
        this.repository = repository;
    }

    public List<Propiedad> findAll() {
        return repository.findAll();
    }

    public Optional<Propiedad> findById(Long id) {
        return repository.findById(id);
    }

    public Propiedad create(Propiedad recurso) {
        return repository.save(recurso);
    }

    public Optional<Propiedad> update(Long id, Propiedad datos) {
        return repository.findById(id).map(existente -> {
            existente.setNombre(datos.getNombre());
            existente.setTipo(datos.getTipo());
            existente.setPrecio(datos.getPrecio());
            return repository.save(existente);
        });
    }

    public boolean delete(Long id) {
        return repository.findById(id).map(existente -> {
            repository.delete(existente);
            return true;
        }).orElse(false);
    }
}
