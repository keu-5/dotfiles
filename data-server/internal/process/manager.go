package process

import "github.com/shirou/gopsutil/v3/process"

type Manager struct{}

func New() *Manager {
	return &Manager{}
}

func (m *Manager) KillByName(name string) error {
	processes, err := process.Processes()
	if err != nil {
		return err
	}

	for _, p := range processes {
		pName, _ := p.Name()
		if pName == name {
			return p.Kill()
		}
	}

	return nil
}

func (m *Manager) KillMultiple(names []string) error {
	for _, name := range names {
		if err := m.KillByName(name); err != nil {
			// ログ出力してcontinue
			continue
		}
	}

	return nil
}
